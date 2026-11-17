// SubagentStop (matcher design-system-keeper): записывает время завершения проверки.
// commit-gate.mjs сравнивает его с временем последней правки Swift-файлов.
import { mkdirSync, writeFileSync, appendFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { readStdinJson, stampPath } from './lib.mjs';

const input = await readStdinJson();
const agent = input.agent_type || input.subagent_type || input.agent_name || '';
mkdirSync(dirname(stampPath), { recursive: true });
appendFileSync(join(dirname(stampPath), 'subagent-stop.log'),
  `${new Date().toISOString()} agent=${agent || '?'} keys=${Object.keys(input).join(',')}\n`);

// Если тип агента известен и это не keeper, отметку не ставим.
if (agent && agent !== 'design-system-keeper') process.exit(0);
if (!agent) process.exit(0); // без типа агента отметку не ставим: лучше лишний запуск keeper, чем ложный пропуск

const report = String(input.last_assistant_message || '').slice(0, 2000);
writeFileSync(stampPath, JSON.stringify({ time: Date.now(), agent, report }, null, 2));
