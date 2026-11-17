import Foundation
import Observation

/// Строка истории измерений, уже отформатированная для показа.
struct PressureHistoryRow: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let zone: PressureZone
}

@MainActor
@Observable
final class PressureViewModel {
    private static let historyLimit = 20
    /// Пауза перед автоматическим открытием шторки (для UI-тестов), чтобы закончилась анимация перехода.
    static let sheetOpenDelayNanoseconds: UInt64 = 600_000_000

    private let store: HealthStore
    @ObservationIgnored private let now: () -> Date

    var period: PressurePeriod = .week
    var isSheetPresented = false
    var draft: MeasurementDraft
    var focusedField: MeasurementField = .systolic
    /// Для UI-тестов: открыть шторку сразу после появления экрана.
    var opensSheetOnAppear = false

    init(store: HealthStore, now: @escaping () -> Date = { Date() }) {
        self.store = store
        self.now = now
        self.draft = MeasurementDraft(date: now())
    }

    // MARK: - Данные экрана

    var screenState: ScreenState { store.screenState }

    var periodMeasurements: [PressureMeasurement] {
        PressureAggregator.measurements(store.data.pressure, in: period, now: now())
    }

    var summary: PressureSummary {
        PressureAggregator.summary(store.data.pressure, period: period, now: now())
    }

    /// Последнее измерение вообще (не только за период).
    var latest: PressureMeasurement? { store.data.pressure.first }

    var history: [PressureMeasurement] {
        Array(periodMeasurements.reversed().prefix(Self.historyLimit))
    }

    /// Строки истории: значение · пульс, дата и контекст, зона.
    var historyRows: [PressureHistoryRow] {
        let current = now()
        return history.map { item in
            PressureHistoryRow(
                id: item.id,
                title: AppFormat.measurementTitle(item),
                subtitle: AppFormat.measurementSubtitle(item, now: current),
                zone: item.zone
            )
        }
    }

    /// Текст крупного значения последнего измерения.
    var latestValueText: String {
        guard let latest else { return AppFormat.emptyPressureValue }
        return AppFormat.pressureValue(latest.systolic, latest.diastolic)
    }

    var rangeText: String {
        guard let top = summary.systolicRange, let bottom = summary.diastolicRange else { return AppFormat.dash }
        return "\(AppFormat.range(top)) / \(AppFormat.range(bottom))"
    }

    var averageText: String {
        guard let top = summary.averageSystolic, let bottom = summary.averageDiastolic else { return AppFormat.dash }
        return AppFormat.pressureValue(top, bottom)
    }

    var pulseText: String {
        AppFormat.pulseValue(latest?.pulse)
    }

    var latestDateText: String {
        guard let latest else { return AppFormat.noMeasurements }
        return AppFormat.historyDate(latest.date, now: now())
    }

    /// Дата в шторке: текущий момент относительно «сейчас», а не относительно самой даты черновика.
    var draftDateText: String {
        AppFormat.historyDate(draft.date, now: now())
    }

    // MARK: - График

    var chartXDomain: ClosedRange<Date> {
        let end = max(now(), periodMeasurements.last?.date ?? now())
        // Небольшой запас справа, чтобы маркер последней точки не обрезался краем графика.
        let padding = Double(period.days) * 86_400 * 0.03
        return period.startDate(now: end)...end.addingTimeInterval(padding)
    }

    var chartYDomain: ClosedRange<Int> {
        let items = periodMeasurements
        let low = min(60, (items.map(\.diastolic).min() ?? 60) - 5)
        let high = max(160, (items.map(\.systolic).max() ?? 160) + 10)
        return low...high
    }

    var chartAccessibilityValue: String {
        let count = summary.count
        guard count > 0 else { return "\(AppFormat.noMeasurements) за период" }
        return "Измерений: \(count). Диапазон: \(rangeText). Среднее: \(averageText)"
    }

    // MARK: - Форма и карточки

    /// Состояние последнего измерения: определяет палитру формы.
    var latestState: HealthState {
        latest.map { HealthState(zone: $0.zone) } ?? .noData
    }

    var latestStatusText: String {
        latest?.zone.title ?? AppFormat.noData
    }

    /// Строка под значением в форме: «мм рт. ст. · пульс 68».
    var orbUnitText: String {
        guard let pulse = latest?.pulse else { return AppUnit.pressure }
        return "\(AppUnit.pressure) · пульс \(pulse)"
    }

    /// Дата и контекст под формой: «Сегодня, 08:10 · Утро».
    var latestSubtitleText: String {
        guard let latest else { return AppFormat.noMeasurements }
        return AppFormat.measurementSubtitle(latest, now: now())
    }

    var latestAccessibilityText: String {
        guard let latest else { return "Последнее измерение: \(AppFormat.noMeasurements)" }
        return "Последнее измерение \(latest.systolic) на \(latest.diastolic), \(latest.zone.title.lowercased())"
    }

    /// Пояснение к зоне последнего измерения для карточки «Почему такой статус».
    var explanationText: String {
        latest?.zone.explanation ?? "Добавьте измерение, чтобы увидеть пояснение по зоне."
    }

    /// Строка результата в шторке: «Будет: Норма» или подсказка ввести значения.
    var draftResultText: String {
        guard let zone = draft.zone else { return "Введите значения" }
        return "Будет: \(zone.title)"
    }

    /// Зона среднего за период.
    var averageZone: PressureZone? {
        guard let top = summary.averageSystolic, let bottom = summary.averageDiastolic else { return nil }
        return PressureZone.classify(systolic: top, diastolic: bottom)
    }

    var averageStatusText: String {
        averageZone?.title ?? AppFormat.noData
    }

    var systolicRangeText: String {
        AppFormat.range(summary.systolicRange)
    }

    /// «В норме N из M»: сколько измерений периода попали в зону нормы.
    var inNormText: String {
        let total = periodMeasurements.count
        guard total > 0 else { return AppFormat.noMeasurements }
        let normal = periodMeasurements.filter { $0.zone == .normal }.count
        return "В норме \(normal) из \(total)"
    }

    // MARK: - Загрузка

    func load() async {
        await store.loadIfNeeded()
    }

    func reload() async {
        await store.load()
    }

    /// Открывает шторку после появления экрана, если это запрошено (UI-тесты).
    func presentSheetIfRequested() async {
        guard opensSheetOnAppear else { return }
        opensSheetOnAppear = false
        try? await Task.sleep(nanoseconds: Self.sheetOpenDelayNanoseconds)
        openSheet()
    }

    // MARK: - Шторка

    func openSheet() {
        draft = MeasurementDraft(date: now())
        focusedField = .systolic
        isSheetPresented = true
    }

    func focus(_ field: MeasurementField) {
        focusedField = field
    }

    func inputDigit(_ digit: Int) {
        if draft.append(digit: digit, to: focusedField) {
            focusedField = focusedField.next
        }
    }

    func deleteDigit() {
        draft.deleteLast(from: focusedField)
    }

    /// Кнопки − и +: меняют значение в выбранном поле на `delta` в пределах правил валидации.
    /// Пустое поле получает типичное значение.
    func stepFocused(by delta: Int) {
        let limits: ClosedRange<Int>
        let fallback: Int
        switch focusedField {
        case .systolic:
            limits = MeasurementDraft.systolicLimits
            fallback = 120
        case .diastolic:
            limits = MeasurementDraft.diastolicLimits
            fallback = 80
        case .pulse:
            limits = MeasurementDraft.pulseLimits
            fallback = 70
        }
        let current = draft.text(for: focusedField)
        let next = Int(current).map { min(max($0 + delta, limits.lowerBound), limits.upperBound) } ?? fallback
        switch focusedField {
        case .systolic: draft.systolicText = String(next)
        case .diastolic: draft.diastolicText = String(next)
        case .pulse: draft.pulseText = String(next)
        }
    }

    func toggleContext(_ context: MeasurementContext) {
        draft.context = draft.context == context ? nil : context
    }

    func save() {
        guard let measurement = draft.makeMeasurement(id: UUID().uuidString) else { return }
        store.add(measurement)
        isSheetPresented = false
    }
}
