# Чек-лист надёжности по diff

Каждый пункт срабатывает по триггеру, видимому в diff (пути изменённых файлов), и появился из
конкретного дефекта или риска. Агент проверяет **только** пункты с совпавшим триггером:

```bash
node scripts/checklist.mjs            # незакоммиченные изменения (или последний коммит, если их нет)
node scripts/checklist.mjs HEAD~3..HEAD
```

Как пополнять: каждый исправленный дефект из `docs/QA-LOG.md` превращается в тест, хук или пункт этого
списка (столбец «Правило» в журнале). Раз в итерацию устаревшие пункты удаляются (см. `CLAUDE.md`).

Формат строки строгий, его читает скрипт: `| ID | glob[, glob] | что проверить | откуда |`.

| ID | Триггер | Что проверить | Откуда |
|----|---------|---------------|--------|
| C01 | HealthMonitor/Data/HealthStore.swift, HealthMonitor/Features/**/*View.swift | Загрузка не зависит от отмены `.task` вызывающего экрана; запуск с `-uiScreen pressure` доходит до данных; `HealthStoreLoadingTests` зелёный. | QA-001 (гонка загрузки) |
| C02 | HealthMonitor/Features/**/*ViewModel.swift | Нет дублей методов после слияния правок (`invalid redeclaration`); каждый публичный метод покрыт тестом. | QA-002 |
| C03 | HealthMonitor/Features/**/*.swift | Помощники для `#Preview`, которые создают ViewModel или Store, помечены `@MainActor`. | QA-003 |
| C04 | HealthMonitor/Domain/AppFormat.swift, HealthMonitor/Domain/PressureAggregation.swift, HealthMonitor/Features/Pressure/PressureChartView.swift | Даты и оси на русском (`AppFormat.locale`); `testAxisFormatPerPeriod` зелёный; на скриншоте нет английских подписей. | QA-004 |
| C05 | HealthMonitor/Domain/PressureZone*.swift | Границы 129/84, 130/85, 139/89, 140/90 и property-тесты зон зелёные; тексты без диагнозов (правило 6). | CLAUDE.md, правило 6 |
| C06 | HealthMonitor/DesignSystem/**, docs/DESIGN.md | Новые токены описаны в DESIGN.md; у нового компонента `#Preview` на каждое состояние; snapshot-тесты зелёные или эталон обновлён осознанно. | QA-007 |
| C07 | HealthMonitor/Features/** | У экрана есть loading, empty, error и данные; для каждого есть snapshot и аудит доступности. | CLAUDE.md, правило 4 |
| C08 | HealthMonitor/App/LaunchConfig.swift, HealthMonitorUITests/** | Все режимы `-uiScreen` покрыты UI-тестом и аудитом; идентификаторы, на которые ждут тесты, существуют в коде. | QA-001 |
| C09 | HealthMonitor/DesignSystem/AuraOrb.swift, HealthMonitor/DesignSystem/Motion.swift | Вращение выключается при `accessibilityReduceMotion` и `isAmbientMotionEnabled == false`; snapshot-кадры детерминированы. | snapshot-тесты |
| C10 | project.yml, .github/workflows/** | Проект генерируется XcodeGen; артефакты `screenshots`, `snapshots`, `simulator-video` на месте; время UI-тестов не выросло заметно. | QA-LOG, медленные UI-тесты |
| C11 | HealthMonitor/Data/** | Данные только из `Data/`, без сети (правило 7); моки детерминированы при заданном `now`. | CLAUDE.md, правило 7 |
| C12 | HealthMonitor/DesignSystem/** | Новый View в DesignSystem: поиск по роли (Card, Tile, Button, Glow, Surface) среди существующих; если похожий есть — расширить его параметром, а не создавать новый. Обоснование нового компонента в описании коммита. | QA-009 (три дубля в перестройке главного) |
| C14 | HealthMonitor/Features/**/*View.swift | View не выбирает tone, surface, showsSparkline и тексты по типу показателя: всё это приходит готовым из модели ViewModel и покрыто тестом. | QA-009, второй проход keeper |
| C15 | HealthMonitor/Features/Home/**, docs/design/** | Перед сборкой и перед ревью главного экрана заново снять Figma 47:2127 (`get_screenshot`) и сравнить с `docs/design/home-figma-47-2127.png`; если макет изменился — обновить снимок и DESIGN.md до правок кода. | QA-011 (эталон в Figma поменялся) |
| C13 | HealthMonitor/Features/** | После замены экрана: компоненты, свойства ViewModel и токены без потребителей в продакшене удалены вместе с тестами, которые держат только их. | QA-009 (мёртвый код после перестройки) |
