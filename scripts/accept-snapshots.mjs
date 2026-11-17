#!/usr/bin/env node
// Принимает НОВЫЕ эталоны snapshot-тестов из артефакта CI в HealthMonitorTests/__Snapshots__/.
// Существующие эталоны не перезаписывает никогда: изменить эталон может только человек
// (удалить файл, прогнать CI, просмотреть кадр). Так изменение не может подогнать свою же проверку.
// Использование: node scripts/accept-snapshots.mjs <runId>   (после scripts/ci-summary.mjs)
import { existsSync, readdirSync, statSync, copyFileSync, mkdirSync } from 'node:fs';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const runId = process.argv[2];
if (!runId) { console.error('Укажи runId'); process.exit(1); }
const src = join(root, 'build', 'ci', runId, 'snapshots');
const dst = join(root, 'HealthMonitorTests', '__Snapshots__');
if (!existsSync(src)) { console.error(`Нет ${src}. Сначала: node scripts/ci-summary.mjs ${runId}`); process.exit(1); }

const walk = d => readdirSync(d).flatMap(f => statSync(join(d, f)).isDirectory() ? walk(join(d, f)) : [join(d, f)]);
let added = 0, skipped = 0;
for (const file of walk(src).filter(f => f.endsWith('.png'))) {
  const target = join(dst, relative(src, file));
  if (existsSync(target)) { skipped++; continue; }
  mkdirSync(dirname(target), { recursive: true });
  copyFileSync(file, target);
  console.log(`+ ${relative(root, target)}`);
  added++;
}
console.log(`Добавлено ${added}, пропущено существующих ${skipped}. Просмотри новые кадры перед коммитом.`);
