// Общие помощники хуков. Правила хардкода читаются из .swiftlint.yml (custom_rules),
// чтобы источник правды был один: CI (SwiftLint) и локальные хуки проверяют одно и то же.
import { readFileSync, existsSync } from 'node:fs';
import { join, relative, isAbsolute } from 'node:path';

export const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();

export async function readStdinJson() {
  const chunks = [];
  for await (const c of process.stdin) chunks.push(c);
  const raw = Buffer.concat(chunks).toString('utf8').trim();
  return raw ? JSON.parse(raw) : {};
}

function unquote(v) {
  v = v.trim();
  if (v.startsWith("'") && v.endsWith("'")) return v.slice(1, -1).replace(/''/g, "'");
  if (v.startsWith('"') && v.endsWith('"')) return JSON.parse(v);
  return v;
}

/** custom_rules из .swiftlint.yml: [{ id, name, message, regex, included, excluded }]. */
export function loadRules() {
  const text = readFileSync(join(projectDir, '.swiftlint.yml'), 'utf8');
  const lines = text.split(/\r?\n/);
  const rules = [];
  let inCustom = false;
  let cur = null;
  for (const line of lines) {
    if (/^custom_rules:\s*$/.test(line)) { inCustom = true; continue; }
    if (!inCustom) continue;
    if (/^\S/.test(line)) break; // следующий раздел верхнего уровня
    const ruleHead = line.match(/^ {2}([A-Za-z0-9_]+):\s*$/);
    if (ruleHead) { cur = { id: ruleHead[1] }; rules.push(cur); continue; }
    const kv = line.match(/^ {4}(name|message|regex|included|excluded|severity):\s*(.+)$/);
    if (kv && cur) cur[kv[1]] = unquote(kv[2]);
  }
  return rules.filter(r => r.regex);
}

export function toRel(p) {
  const abs = isAbsolute(p) ? p : join(projectDir, p);
  return relative(projectDir, abs).split('\\').join('/');
}

/** Нарушения в одном файле: [{ file, line, rule, message, text }]. */
export function lintFile(path, rules) {
  const rel = toRel(path);
  if (!rel.endsWith('.swift')) return [];
  const abs = join(projectDir, rel);
  if (!existsSync(abs)) return [];
  const active = rules.filter(r =>
    (!r.included || new RegExp(r.included).test(rel)) &&
    !(r.excluded && new RegExp(r.excluded).test(rel)));
  if (!active.length) return [];
  const out = [];
  readFileSync(abs, 'utf8').split(/\r?\n/).forEach((text, i) => {
    if (text.trim().startsWith('//')) return;
    for (const r of active) {
      if (new RegExp(r.regex).test(text)) {
        out.push({ file: rel, line: i + 1, rule: r.id, message: r.message || r.name, text: text.trim() });
      }
    }
  });
  return out;
}

export function formatViolations(v) {
  return v.map(x => `${x.file}:${x.line} [${x.rule}] ${x.message}\n    ${x.text}`).join('\n');
}

export const stampPath = join(projectDir, '.claude', 'state', 'keeper-last-run.json');
