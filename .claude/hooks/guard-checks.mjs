// PreToolUse (Edit|Write|Bash|PowerShell): изменение не может менять свои проверки.
// Правка защищённых файлов (правила линтера, хуки, настройки, определения агентов, навык verify,
// CI, эталоны snapshot, исключения аудита доступности) уходит на подтверждение человеку (permissionDecision "ask").
// Исключение: scripts/accept-snapshots.mjs добавляет только НОВЫЕ эталоны и ничего не перезаписывает.
import { readStdinJson, toRel } from './lib.mjs';

export const GUARDED = [
  /^\.swiftlint\.yml$/,
  /^\.claude\/settings\.json$/,
  /^\.claude\/hooks\//,
  /^\.claude\/agents\//,
  /^\.claude\/skills\/verify\//,
  /^\.github\/workflows\//,
  /^scripts\//,
  /^HealthMonitorTests\/__Snapshots__\//,
  /^HealthMonitorUITests\/AccessibilityWaivers\.swift$/,
];
const GUARDED_MENTIONS = /\.swiftlint\.yml|\.claude[\\/](settings\.json|hooks|agents|skills[\\/]verify)|\.github[\\/]workflows|__Snapshots__|AccessibilityWaivers|scripts[\\/]/;
const MUTATING = /(^|[\s;&|(])(rm|mv|cp|tee|unzip|truncate|perl\s+-i|sed\s+-i|git\s+(rm|mv|checkout|restore|reset|apply)|Remove-Item|Move-Item|Copy-Item|Set-Content|Add-Content|Out-File|Rename-Item|del|move|copy)\b|>{1,2}/;

const ask = reason => {
  process.stdout.write(JSON.stringify({
    hookSpecificOutput: { hookEventName: 'PreToolUse', permissionDecision: 'ask', permissionDecisionReason: reason },
  }));
  process.exit(0);
};

const input = await readStdinJson();
const tool = input.tool_name || '';
const ti = input.tool_input || {};

if (tool === 'Edit' || tool === 'Write' || tool === 'NotebookEdit') {
  const rel = toRel(ti.file_path || ti.notebook_path || '');
  if (GUARDED.some(re => re.test(rel))) {
    ask(`Защищённый файл проверок: ${rel}. Его меняет только человек и отдельным коммитом (CLAUDE.md, «Верификация», п. 3).`);
  }
  process.exit(0);
}

const command = String(ti.command || '');
if (!command) process.exit(0);
if (/^\s*node\s+scripts[\\/]accept-snapshots\.mjs\s+\d+\s*$/.test(command)) process.exit(0);
if (GUARDED_MENTIONS.test(command) && MUTATING.test(command)) {
  ask('Команда может изменить защищённые файлы проверок (эталоны, исключения аудита, линтер, хуки, CI). Нужно подтверждение человека.');
}
