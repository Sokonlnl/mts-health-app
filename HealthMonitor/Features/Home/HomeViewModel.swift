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
            statusText: AppFormat.restingStatus,
            tone: .positive,
            series: reading.series
        )
    }

    /// Вес показывается только значением в плитке бенто, без статуса и графика.
    private func weightCard(_ reading: MetricReading) -> MetricCardModel {
        guard let latest = reading.latest else { return .empty(.weight, unit: AppUnit.weight) }
        return MetricCardModel(
            kind: .weight,
            valueText: AppFormat.decimal(latest),
            unit: AppUnit.weight,
            statusText: AppFormat.lastValue,
            tone: .neutral,
            series: reading.series
        )
    }

    private func glucoseCard(_ reading: MetricReading) -> MetricCardModel {
        guard let latest = reading.latest else { return .empty(.glucose, unit: AppUnit.glucose) }
        return MetricCardModel(
            kind: .glucose,
            valueText: AppFormat.decimal(latest),
            unit: AppUnit.glucose,
            statusText: AppFormat.lastValue,
            tone: .neutral,
            series: reading.series
        )
    }
}
