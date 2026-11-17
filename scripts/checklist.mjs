#!/usr/bin/env node
// Печатает пункты docs/CHECKLIST.md, чей триггер совпал с изменёнными файлами.
// Использование: node scripts/checklist.mjs [git-range]
// Без аргумента: незакоммиченные изменения; если их нет, последний коммит.
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const git = (...a) => execFileSync('git', a, { cwd: root, encoding: 'utf8' })
  .split('\n').map(s => s.trim()).filter(Boolean);

let files;
const range = process.argv[2];
if (range) {
  files = git('diff', '--name-only', range);
} else {
  files = [...new Set([
    ...git('diff', '--name-only', 'HEAD'),
    ...git('ls-files', '--others', '--exclude-standard'),
  ])];
  if (!files.length) files = git('diff', '--name-only', 'HEAD~1..HEAD');
}

const globToRe = g => new RegExp('^' + g.trim()
  .replace(/[.+^${}()|[\]\\]/g, '\\$&')
  .replace(/\*\*\/?/g, '\u0000')
  .replace(/\*/g, '[^/]*')
  .replace(/\u0000/g, '(?:.*/)?')
  .replace(/\(\?:\.\*\/\)\?$/, '.*') + '$');

const rows = readFileSync(join(root, 'docs', 'CHECKLIST.md'), 'utf8').split(/\r?\n/)
  .map(l => l.match(/^\|\s*(C\d+)\s*\|([^|]+)\|([^|]+)\|([^|]+)\|/))
  .filter(Boolean)
  .map(([, id, trig, what, from]) => ({ id, globs: trig.split(',').map(globToRe), what: what.trim(), from: from.trim() }));

const hits = rows
  .map(r => ({ ...r, matched: files.filter(f => r.globs.some(re => re.test(f))) }))
  .filter(r => r.matched.length);

console.log(`Изменённых файлов: ${files.length}. Совпавших пунктов: ${hits.length} из ${rows.length}.`);
for (const h of hits) {
  console.log(`\n${h.id} (${h.from})\n  Проверить: ${h.what}\n  Файлы: ${h.matched.slice(0, 5).join(', ')}${h.matched.length > 5 ? ' …' : ''}`);
}
