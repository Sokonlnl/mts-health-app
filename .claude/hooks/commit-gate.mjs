// PreToolUse (Bash|PowerShell): ворота перед `git commit`.
// 1. Хардкод в изменённых Swift-файлах блокирует коммит.
// 2. Если Swift-файлы менялись после последнего запуска design-system-keeper, коммит блокируется
//    (правило 4 из CLAUDE.md: «коммит Swift-кода без проверки keeper запрещён»).
// Отметку о запуске keeper ставит keeper-stamp.mjs (SubagentStop).
import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { readStdinJson, loadRules, lintFile, formatViolations, projectDir, stampPath } from './lib.mjs';

const input = await readStdinJson();
const command = String(input?.tool_input?.command || '');
if (!/\bgit\b[^\n]*\bcommit\b/.test(command)) process.exit(0);

const git = (...args) =>
  execFileSync('git', args, { cwd: projectDir, encoding: 'utf8' }).split('\n').map(s => s.trim()).filter(Boolean);

// Staged + изменённые + новые: команда может сама делать `git add` перед `git commit`.
const files = [...new Set([
  ...git('diff', '--cached', '--name-only', '--diff-filter=ACMR'),
  ...git('diff', '--name-only', '--diff-filter=ACMR'),
  ...git('ls-files', '--others', '--exclude-standard'),
])].filter(f => f.endsWith('.swift'));

if (!files.length) process.exit(0);

const problems = [];

const violations = files.flatMap(f => lintFile(f, loadRules()));
if (violations.length) {
  problems.push(`Хардкод вне DesignSystem/:\n${formatViolations(violations)}`);
}

const newest = Math.max(...files.map(f => {
  const p = join(projectDir, f);
  return existsSync(p) ? statSync(p).mtimeMs : 0;
}));
let stamp = null;
try { stamp = JSON.parse(readFileSync(stampPath, 'utf8')); } catch { /* нет отметки */ }
if (!stamp || stamp.time < newest) {
  problems.push(
    'design-system-keeper не запускался после последних правок Swift-файлов ' +
    `(${files.length} файлов, последняя правка ${new Date(newest).toISOString()}` +
    (stamp ? `, последний запуск keeper ${new Date(stamp.time).toISOString()}` : ', запусков keeper не было') +
    '). Запусти агента design-system-keeper, исправь найденное и повтори коммит.'
  );
}

if (problems.length) {
  process.stderr.write(`Коммит остановлен (.claude/hooks/commit-gate.mjs):\n\n${problems.join('\n\n')}\n`);
  process.exit(2);
}
