import CoreGraphics
import Foundation
import Observation

/// Плашка зоны в карточке «Почему такой статус».
struct ZonePlate: Identifiable, Equatable {
    let title: String
    let threshold: String
    let tone: StatusTone
    let isCurrent: Bool
    var id: String { title }

    static func plates(current: PressureZone?) -> [ZonePlate] {
        PressureZone.allCases.map {
            ZonePlate(title: $0.title, threshold: $0.thresholdText, tone: $0.tone, isCurrent: $0 == current)
        }
    }
}

@MainActor
@Observable
final class PressureViewModel {
    let store: HealthStore
    @ObservationIgnored let now: () -> Date

    var period: PressurePeriod = .week
    /// Колода советов ГигаЧата под показателями.
    private var adviceDeck = AdviceDeck()

    init(store: HealthStore, now: @escaping () -> Date = { Date() }) {
        self.store = store
        self.now = now
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

    // MARK: - Советы ГигаЧата

    /// Оставшиеся карточки колоды (верхняя первая); порядок по зоне последнего измерения.
    var adviceCards: [AdviceCardModel] {
        let zone = latest?.zone
        let disclaimer = AdviceSelector.disclaimer(for: zone)
        let ordered = adviceDeck.remaining(AdviceSelector.ordered(store.data.advice, zone: zone))
        return ordered.map {
            AdviceCardModel(
                id: $0.id, title: $0.title, text: $0.text, author: HomeText.gigachatName, role: HomeText.gigachatRole,
                iconName: HomeText.gigachatMarkAsset, disclaimer: disclaimer
            )
        }
    }

    /// Подпись положения для VoiceOver: «Совет 2 из 4».
    var advicePositionText: String {
        let count = store.data.advice.count
        return HomeText.advicePosition(adviceDeck.position(count: count), of: count)
    }

    var hasAdvice: Bool { !store.data.advice.isEmpty }

    func dismissAdvice() { adviceDeck.dismissTop(count: store.data.advice.count) }

    func refreshAdvice() { adviceDeck.refresh(count: store.data.advice.count) }

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

    var latestTone: StatusTone { latestState.tone }

    var latestIsPlaceholder: Bool { latest == nil }

    var zonePlates: [ZonePlate] { ZonePlate.plates(current: latest?.zone) }

    var latestStatusText: String {
        latest?.zone.title ?? AppFormat.noData
    }

    /// Строка под значением в верхнем блоке: «мм рт. ст. · пульс 68».
    var latestUnitText: String {
        AppFormat.pressureUnit(pulse: latest?.pulse)
    }

    /// Высота верхнего блока: при ошибке компактная (значения нет), иначе полная (Figma 86:123).
    var heroHeight: CGFloat {
        if case .error = screenState { return Size.heroCompactHeight }
        return Size.metricHeroHeight
    }

    /// Сердце в верхнем блоке бьётся в ритме пульса последнего измерения; без измерений неподвижно.
    var heartRhythm: HeartbeatRhythm? {
        latest.map { HeartbeatRhythm(pulse: $0.pulse) }
    }

    /// Подпись под верхним блоком: дата, контекст и пульс последнего измерения («Сегодня, 08:31 · Утро · пульс 60»).
    var latestCaptionText: String {
        guard let latest else { return "" }
        let pulse = latest.pulse.map { "пульс \($0)" }
        return [AppFormat.measurementSubtitle(latest, now: now()), pulse].compactMap { $0 }.joined(separator: " · ")
    }

    /// Есть ли измерения в выбранном периоде (иначе под графиком и в истории подпись «За выбранный период измерений нет.»).
    var hasPeriodMeasurements: Bool { !periodMeasurements.isEmpty }

    var emptyPeriodMessage: String { AppFormat.emptyPeriod }

    /// Подсказка пустого экрана (нет ни одного измерения).
    var emptyMessage: String { "Измерений пока нет. Здесь появятся график и история." }

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
        latest?.zone.explanation ?? "Пока нет измерений, пояснение по зоне недоступно."
    }

    /// Зона среднего за период.
    var averageZone: PressureZone? {
        guard let top = summary.averageSystolic, let bottom = summary.averageDiastolic else { return nil }
        return PressureZone.classify(systolic: top, diastolic: bottom)
    }

    /// Тон статуса среднего за период (цвет подписи под значением в карточке «Среднее»).
    var averageTone: StatusTone { averageZone?.tone ?? .neutral }

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
}
