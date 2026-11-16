import Foundation
import Observation

/// Данные кольца на главном экране.
struct RingItem: Identifiable, Equatable {
    let kind: MetricKind
    let centerText: String
    let progress: Double
    let isEmpty: Bool

    var id: String { kind.id }

    var accessibilityText: String {
        isEmpty ? "нет данных" : "в норме \(centerText) дней"
    }
}

/// Данные карточки показателя.
struct MetricCardModel: Identifiable, Equatable {
    let kind: MetricKind
    let valueText: String?
    let unit: String
    let statusText: String
    let tone: StatusTone
    let series: [Double]

    var id: String { kind.id }

    static func empty(_ kind: MetricKind, unit: String) -> MetricCardModel {
        MetricCardModel(kind: kind, valueText: nil, unit: unit, statusText: "Нет данных", tone: .neutral, series: [])
    }
}

@MainActor
@Observable
final class HomeViewModel {
    private let store: HealthStore
    @ObservationIgnored private let now: () -> Date

    var isInsightExpanded = false

    init(store: HealthStore, now: @escaping () -> Date = { Date() }) {
        self.store = store
        self.now = now
    }

    var screenState: ScreenState { store.screenState }

    var dateTitle: String { "Сегодня, \(AppFormat.longDate(now()))" }

    var syncText: String? {
        store.lastSync.map { "Синхронизировано в \(AppFormat.time($0))" }
    }

    var weekDays: [WeekDay] {
        WeekOverview.days(measurements: store.data.pressure, now: now())
    }

    var insight: WeekInsight {
        WeekInsight.make(stats: WeekOverview.stats(measurements: store.data.pressure, now: now()))
    }

    var rings: [RingItem] {
        let data = store.data
        let pressureDays = WeekOverview.stats(measurements: data.pressure, now: now()).normalDays
        return [
            ring(.pressure, days: pressureDays, hasData: !data.pressure.isEmpty),
            ring(.pulse, days: data.pulse.daysInNorm, hasData: data.pulse.latest != nil),
            ring(.weight, days: data.weight.daysInNorm, hasData: data.weight.latest != nil)
        ]
    }

    var cards: [MetricCardModel] {
        let data = store.data
        return [
            pressureCard(data.pressure),
            pulseCard(data.pulse),
            weightCard(data.weight),
            glucoseCard(data.glucose)
        ]
    }

    func load() async {
        await store.loadIfNeeded()
    }

    func reload() async {
        await store.load()
    }

    func toggleInsight() {
        isInsightExpanded.toggle()
    }

    private func ring(_ kind: MetricKind, days: Int, hasData: Bool) -> RingItem {
        RingItem(
            kind: kind,
            centerText: hasData ? "\(days)/7" : AppFormat.dash,
            progress: hasData ? Double(days) / 7 : 0,
            isEmpty: !hasData
        )
    }

    private func pressureCard(_ measurements: [PressureMeasurement]) -> MetricCardModel {
        guard let latest = measurements.first else { return .empty(.pressure, unit: "мм рт. ст.") }
        let series = measurements.prefix(14).reversed().map { Double($0.systolic) }
        return MetricCardModel(
            kind: .pressure,
            valueText: AppFormat.pressureValue(latest.systolic, latest.diastolic),
            unit: "мм рт. ст.",
            statusText: latest.zone.title,
            tone: latest.zone.tone,
            series: series
        )
    }

    private func pulseCard(_ reading: MetricReading) -> MetricCardModel {
        guard let latest = reading.latest else { return .empty(.pulse, unit: "уд/мин") }
        return MetricCardModel(
            kind: .pulse,
            valueText: "\(Int(latest.rounded()))",
            unit: "уд/мин",
            statusText: "В покое",
            tone: .neutral,
            series: reading.series
        )
    }

    private func weightCard(_ reading: MetricReading) -> MetricCardModel {
        guard let latest = reading.latest else { return .empty(.weight, unit: "кг") }
        var status = "Без изменений"
        if let first = reading.series.first, let last = reading.series.last {
            status = "\(AppFormat.signedDecimal(last - first)) кг за 2 недели"
        }
        return MetricCardModel(
            kind: .weight,
            valueText: AppFormat.decimal(latest),
            unit: "кг",
            statusText: status,
            tone: .neutral,
            series: reading.series
        )
    }

    private func glucoseCard(_ reading: MetricReading) -> MetricCardModel {
        guard let latest = reading.latest else { return .empty(.glucose, unit: "ммоль/л") }
        return MetricCardModel(
            kind: .glucose,
            valueText: AppFormat.decimal(latest),
            unit: "ммоль/л",
            statusText: "Последнее значение",
            tone: .neutral,
            series: reading.series
        )
    }
}
