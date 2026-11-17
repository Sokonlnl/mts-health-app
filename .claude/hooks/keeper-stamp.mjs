// SubagentStop (matcher design-system-keeper): записывает хеш содержимого Swift-файлов,
// которое проверил keeper. commit-gate.mjs сравнивает его с текущим хешем.
import { mkdirSync, writeFileSync, appendFileSync } from 'node:fs';
import { join } from 'node:path';
import { readStdinJson, stampPath, stateDir, swiftContentHash } from './lib.mjs';

const input = await readStdinJson();
const agent = input.agent_type || '';
mkdirSync(stateDir, { recursive: true });
appendFileSync(join(stateDir, 'subagent-stop.log'), `${new Date().toISOString()} agent=${agent || '?'}\n`);

// Отметку ставит только keeper. Без типа агента отметки нет: лучше лишний запуск, чем ложный пропуск.
if (agent !== 'design-system-keeper') process.exit(0);

const hash = await swiftContentHash();
writeFileSync(stampPath, JSON.stringify({ time: Date.now(), hash, agent }, null, 2));
