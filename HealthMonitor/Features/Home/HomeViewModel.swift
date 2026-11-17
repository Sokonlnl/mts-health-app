import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    let store: HealthStore
    @ObservationIgnored let now: () -> Date

    var isInsightExpanded = false

    init(store: HealthStore, now: @escaping () -> Date = { Date() }) {
        self.store = store
        self.now = now
    }

    var screenState: ScreenState { store.screenState }

    var insight: WeekInsight {
        WeekInsight.make(stats: WeekOverview.stats(measurements: store.data.pressure, now: now()))
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

    func card(_ kind: MetricKind) -> MetricCardModel {
        cards.first { $0.kind == kind } ?? .empty(kind, unit: "")
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

    private func pressureCard(_ measurements: [PressureMeasurement]) -> MetricCardModel {
        guard let latest = measurements.first else { return .empty(.pressure, unit: AppUnit.pressure) }
        let series = measurements.prefix(14).reversed().map { Double($0.systolic) }
        return MetricCardModel(
            kind: .pressure,
            valueText: AppFormat.pressureValue(latest.systolic, latest.diastolic),
            unit: AppUnit.pressure,
            statusText: latest.zone.title,
            tone: latest.zone.tone,
            series: series
        )
    }

    private func pulseCard(_ reading: MetricReading) -> MetricCardModel {
        guard let latest = reading.latest else { return .empty(.pulse, unit: AppUnit.pulse) }
        return MetricCardModel(
            kind: .pulse,
            valueText: "\(Int(latest.rounded()))",
            unit: AppUnit.pulse,
            statusText: "В покое",
            tone: .positive,
            series: reading.series
        )
    }

    private func weightCard(_ reading: MetricReading) -> MetricCardModel {
        guard let latest = reading.latest else { return .empty(.weight, unit: AppUnit.weight) }
        var status = "Без изменений"
        if let first = reading.series.first, let last = reading.series.last {
            status = "\(AppFormat.signedDecimal(last - first)) кг за 2 недели"
        }
        return MetricCardModel(
            kind: .weight,
            valueText: AppFormat.decimal(latest),
            unit: AppUnit.weight,
            statusText: status,
            tone: .positive,
            series: reading.series,
            showsSparkline: false
        )
    }

    private func glucoseCard(_ reading: MetricReading) -> MetricCardModel {
        guard let latest = reading.latest else { return .empty(.glucose, unit: AppUnit.glucose) }
        return MetricCardModel(
            kind: .glucose,
            valueText: AppFormat.decimal(latest),
            unit: AppUnit.glucose,
            statusText: "Последнее значение",
            tone: .neutral,
            series: reading.series
        )
    }
}
