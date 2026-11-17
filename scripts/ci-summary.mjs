#!/usr/bin/env node
// Сводка по запуску CI для навыка verify: статус, упавшие тесты, отчёты аудита доступности,
// снимки snapshot-тестов (новые эталоны и diff). Артефакты кладутся в build/ci/<run>/ (не в Git).
// Использование: node scripts/ci-summary.mjs [runId]   (без аргумента: последний запуск)
import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync, rmSync, mkdirSync, statSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const ghCandidates = ['gh', 'C:\\Program Files\\GitHub CLI\\gh.exe'];
const ghBin = ghCandidates.find(b => { try { execFileSync(b, ['--version'], { stdio: 'ignore' }); return true; } catch { return false; } });
if (!ghBin) { console.error('gh CLI не найден'); process.exit(1); }
const gh = (...a) => execFileSync(ghBin, a, { cwd: root, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });

const runId = process.argv[2] || JSON.parse(gh('run', 'list', '--limit', '1', '--json', 'databaseId'))[0].databaseId;
const run = JSON.parse(gh('run', 'view', String(runId), '--json', 'status,conclusion,headSha,displayTitle,url,jobs'));
console.log(`CI ${runId}: ${run.status} ${run.conclusion || ''}\nКоммит: ${run.headSha.slice(0, 7)} ${run.displayTitle}\n${run.url}`);
for (const job of run.jobs || []) {
  const failed = (job.steps || []).filter(s => s.conclusion === 'failure').map(s => s.name);
  console.log(`Job ${job.name}: ${job.conclusion}${failed.length ? ` (упали шаги: ${failed.join(', ')})` : ''}`);
}
if (run.status !== 'completed') process.exit(0);

const dir = join(root, 'build', 'ci', String(runId));
rmSync(dir, { recursive: true, force: true });
mkdirSync(dir, { recursive: true });
for (const name of ['xcodebuild-log', 'screenshots', 'snapshots']) {
  try { gh('run', 'download', String(runId), '-n', name, '-D', join(dir, name)); } catch { /* артефакта нет */ }
}

// Упавшие тесты и ошибки компиляции из лога.
const logPath = join(dir, 'xcodebuild-log', 'xcodebuild.log');
if (existsSync(logPath)) {
  const log = readFileSync(logPath, 'utf8').split('\n');
  const failedTests = [...new Set(log.filter(l => /Test Case '.*' failed/.test(l)).map(l => l.match(/'-\[(.+?)\]'/)?.[1] || l))];
  const errors = log.filter(l => /error:/.test(l)).slice(0, 20);
  const summary = log.filter(l => /Executed \d+ tests?, with/.test(l)).slice(-3);
  console.log(`\nТесты: ${summary.join(' | ') || 'итог не найден'}`);
  if (failedTests.length) console.log(`Упали (${failedTests.length}):\n  ${failedTests.join('\n  ')}`);
  if (errors.length) console.log(`Ошибки (первые ${errors.length}):\n  ${errors.map(e => e.trim()).join('\n  ')}`);
}

// Вложения: отчёты аудита и diff snapshot-тестов.
const manifestPath = join(dir, 'screenshots', 'manifest.json');
if (existsSync(manifestPath)) {
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  const attachments = manifest.flatMap(t => (t.attachments || []).map(a => ({ test: t.testIdentifier, ...a })));
  const audits = attachments.filter(a => /^a11y-/.test(a.suggestedHumanReadableName || ''));
  for (const a of audits) {
    const text = readFileSync(join(dir, 'screenshots', a.exportedFileName), 'utf8').trim();
    console.log(`\n${a.suggestedHumanReadableName.replace(/_\d+.*$/, '')}:\n  ${text.split('\n').join('\n  ')}`);
  }
  const diffs = attachments.filter(a => /difference|failure|reference/i.test(a.suggestedHumanReadableName || ''));
  if (diffs.length) {
    console.log(`\nSnapshot-расхождения (${diffs.length} файлов):`);
    for (const d of diffs) console.log(`  ${d.test}: ${join('build', 'ci', String(runId), 'screenshots', d.exportedFileName)} (${d.suggestedHumanReadableName})`);
  }
}

// Новые эталоны, записанные в этом прогоне.
const snapDir = join(dir, 'snapshots');
if (existsSync(snapDir)) {
  const walk = d => readdirSync(d).flatMap(f => statSync(join(d, f)).isDirectory() ? walk(join(d, f)) : [join(d, f)]);
  const pngs = walk(snapDir).filter(f => f.endsWith('.png'));
  console.log(`\nЭталоны в артефакте snapshots: ${pngs.length}. Новые принимаются через: node scripts/accept-snapshots.mjs ${runId}`);
}
