// PostToolUse (Edit|Write): сразу после правки Swift-файла ищет хардкод цветов, шрифтов,
// отступов и радиусов по правилам из .swiftlint.yml. Нарушение: exit 2, текст уходит агенту,
// и он исправляет файл в том же ходе, не дожидаясь CI.
import { readStdinJson, loadRules, lintFile, formatViolations } from './lib.mjs';

const input = await readStdinJson();
const file = input?.tool_input?.file_path || input?.tool_response?.filePath;
if (!file || !file.endsWith('.swift')) process.exit(0);

const violations = lintFile(file, loadRules());
if (violations.length) {
  process.stderr.write(
    `Хардкод вне DesignSystem/ (правила из .swiftlint.yml, CI упадёт на swiftlint --strict):\n` +
    formatViolations(violations) +
    `\nЗамени на токены AppColor / AppTextStyle / Spacing / Radius / Size.\n`
  );
  process.exit(2);
}
