// PreToolUse (Bash|PowerShell): ворота перед `git commit`.
// Режим: переменная COMMIT_GATE_MODE в .claude/settings.json → off | observe | enforce (по умолчанию enforce).
//   observe: ничего не блокирует, только пишет в .claude/state/gate.log, что было бы заблокировано
//            (так ловят ложные срабатывания перед включением enforce).
// Проверки, если в рабочей копии есть изменённые Swift-файлы:
//   1. Хардкод вне DesignSystem/ (правила из .swiftlint.yml).
//   2. design-system-keeper проверял ровно текущее содержимое Swift-файлов (хеш, не время).
//   3. В сообщении коммита есть трейлер `Verified-by:`, так видно, как проверен каждый коммит.
// Выход из тупика: после двух блокировок в сессии коммит с трейлером `Gate-override: <причина>` проходит,
// причина пишется в журнал. Так агент не застревает, а обход виден в истории Git.
import { execFileSync } from 'node:child_process';
import { readFileSync, writeFileSync, appendFileSync, mkdirSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { readStdinJson, loadRules, lintFile, formatViolations, projectDir, stampPath, stateDir, swiftContentHash } from './lib.mjs';

const mode = (process.env.COMMIT_GATE_MODE || 'enforce').toLowerCase();
if (mode === 'off') process.exit(0);

const input = await readStdinJson();
const command = String(input?.tool_input?.command || '');
// Только настоящий вызов `git commit` (в начале команды или после ; && || |), а не упоминание в строке.
if (!/(?:^|[;&|\n]\s*|\(\s*)git(?:\s+-[^\s]+(?:\s+[^\s-][^\s]*)?)*\s+commit\b/.test(command)) process.exit(0);

const git = (...args) =>
  execFileSync('git', args, { cwd: projectDir, encoding: 'utf8' }).split('\n').map(s => s.trim()).filter(Boolean);

const files = [...new Set([
  ...git('diff', '--cached', '--name-only', '--diff-filter=ACMR'),
  ...git('diff', '--name-only', '--diff-filter=ACMR'),
  ...git('ls-files', '--others', '--exclude-standard'),
])].filter(f => f.endsWith('.swift'));

mkdirSync(stateDir, { recursive: true });
const log = msg => appendFileSync(join(stateDir, 'gate.log'), `${new Date().toISOString()} [${mode}] ${msg}\n`);

if (!files.length) { log('pass: нет изменённых Swift-файлов'); process.exit(0); }

const problems = [];

const violations = files.flatMap(f => lintFile(f, loadRules()));
if (violations.length) problems.push(`Хардкод вне DesignSystem/:\n${formatViolations(violations)}`);

// UI-тесты — отдельный таргет без @testable import: типы приложения там не компилируются (QA-019).
const appTypes = new Set();
for (const f of git('ls-files', '-co', '--exclude-standard', '--', 'HealthMonitor/*.swift', 'HealthMonitor/**/*.swift')) {
  const p = join(projectDir, f);
  if (!existsSync(p)) continue;
  for (const m of readFileSync(p, 'utf8').matchAll(/^\s*(?:@\w+\s+)*(?:public\s+|internal\s+|private\s+|fileprivate\s+|final\s+)*(?:struct|enum|class|protocol|actor|typealias)\s+([A-Z]\w*)/gm)) {
    appTypes.add(m[1]);
  }
}
const uiRefs = [];
for (const f of files.filter(f => f.startsWith('HealthMonitorUITests/'))) {
  const p = join(projectDir, f);
  if (!existsSync(p)) continue;
  readFileSync(p, 'utf8').split(/\r?\n/).forEach((line, i) => {
    const code = line.replace(/\/\/.*$/, '').replace(/"(?:[^"\\]|\\.)*"/g, '""');
    for (const m of code.matchAll(/\b([A-Z]\w*)\b/g)) {
      if (appTypes.has(m[1])) uiRefs.push(`${f}:${i + 1} ${m[1]}`);
    }
  });
}
if (uiRefs.length) {
  problems.push(`UI-тесты ссылаются на типы приложения (в таргете UI-тестов их нет, сборка упадёт):\n${uiRefs.join('\n')}\n` +
    'Передавай аргументы строками или объяви локальную константу в HealthMonitorUITests.');
}

const hash = await swiftContentHash();
let stamp = null;
try { stamp = JSON.parse(readFileSync(stampPath, 'utf8')); } catch { /* нет отметки */ }
if (!stamp || stamp.hash !== hash) {
  problems.push(
    `design-system-keeper не проверял текущее содержимое Swift-файлов (хеш ${hash}, ` +
    (stamp ? `проверен ${stamp.hash || 'без хеша'})` : 'проверок не было)') +
    '. Запусти design-system-keeper, исправь must-fix и повтори коммит.'
  );
}

if (!/Verified-by:/i.test(command)) {
  problems.push('Нет трейлера `Verified-by:` в сообщении коммита. Пример: `Verified-by: keeper, checklist C01 C05; CI pending`.');
}

if (!problems.length) { log(`pass: ${files.length} Swift, хеш ${hash}`); process.exit(0); }

// Счётчик блокировок в сессии.
const countsPath = join(stateDir, 'gate-blocks.json');
let counts = {};
try { counts = JSON.parse(readFileSync(countsPath, 'utf8')); } catch { /* пусто */ }
const session = input.session_id || 'unknown';
const blocks = counts[session] || 0;
const override = command.match(/Gate-override:\s*([^\n"']+)/i);

if (mode === 'observe') {
  log(`would-block: ${problems.map(p => p.split('\n')[0]).join(' | ')}`);
  process.exit(0);
}
if (blocks >= 2 && override) {
  log(`override after ${blocks} blocks: ${override[1].trim()} | ${problems.map(p => p.split('\n')[0]).join(' | ')}`);
  process.exit(0);
}

counts[session] = blocks + 1;
writeFileSync(countsPath, JSON.stringify(counts, null, 2));
log(`block #${blocks + 1}: ${problems.map(p => p.split('\n')[0]).join(' | ')}`);
process.stderr.write(
  `Коммит остановлен (.claude/hooks/commit-gate.mjs, блокировка ${blocks + 1} в сессии):\n\n${problems.join('\n\n')}\n` +
  (blocks + 1 >= 2 ? '\nЕсли причина неустранима, добавь трейлер `Gate-override: <причина>`: следующий коммит пройдёт, обход попадёт в журнал.\n' : '')
);
process.exit(2);
