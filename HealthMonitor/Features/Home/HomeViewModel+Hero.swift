import Foundation

/// Главный показатель, пилюли и заголовок-вывод главного экрана.
extension HomeViewModel {
    func state(for kind: MetricKind) -> HealthState {
        let data = store.data
        switch kind {
        case .pressure:
            return data.pressure.first.map { HealthState(zone: $0.zone) } ?? .noData
        case .pulse:
            return data.pulse.latest == nil ? .noData : .neutral
        case .weight:
            return data.weight.latest == nil ? .noData : .neutral
        case .glucose:
            return data.glucose.latest == nil ? .noData : .neutral
        }
    }

    var state: HealthState { state(for: selectedKind) }

    var pills: [PillModel] {
        MetricKind.allCases.map { kind in
            let model = card(kind)
            let valueText = model.valueText ?? AppFormat.dash
            return PillModel(
                kind: kind,
                valueText: valueText,
                state: state(for: kind),
                isSelected: kind == selectedKind,
                accessibilityText: model.valueText.map { "\($0) \(model.unit), \(model.statusText)" } ?? AppFormat.noData
            )
        }
    }

    var hero: HeroModel {
        let model = card(selectedKind)
        let current = state
        let statusText = current == .noData ? AppFormat.noData : model.statusText
        return HeroModel(
            kind: selectedKind,
            state: current,
            caption: selectedKind.title,
            valueText: model.valueText ?? (selectedKind == .pressure ? AppFormat.emptyPressureValue : AppFormat.dash),
            unit: model.unit,
            statusText: statusText,
            markerProgress: markerProgress,
            accessibilityText: heroAccessibilityText(model, statusText: statusText)
        )
    }

    var headline: HeadlineModel {
        switch selectedKind {
        case .pressure:
            let current = insight
            return HeadlineModel(title: current.title, summary: current.summary, details: current.details)
        case .pulse:
            return simpleHeadline(.pulse, title: "Пульс в покое", empty: "Измерений пульса пока нет.")
        case .weight:
            return simpleHeadline(.weight, title: "Вес за две недели", empty: "Измерений веса пока нет.")
        case .glucose:
            return simpleHeadline(.glucose, title: "Глюкоза", empty: "Измерений глюкозы пока нет.")
        }
    }

    // MARK: - Помощники

    private func simpleHeadline(_ kind: MetricKind, title: String, empty: String) -> HeadlineModel {
        let model = card(kind)
        guard let value = model.valueText else {
            return HeadlineModel(title: AppFormat.noData, summary: empty, details: nil)
        }
        return HeadlineModel(title: title, summary: "\(model.statusText). Последнее значение: \(value) \(model.unit).", details: nil)
    }

    private func heroAccessibilityText(_ model: MetricCardModel, statusText: String) -> String {
        guard let latest = store.data.pressure.first, selectedKind == .pressure else {
            guard let value = model.valueText else { return "\(selectedKind.title), \(AppFormat.noData)" }
            return "\(selectedKind.title) \(value) \(model.unit), \(statusText)"
        }
        return "Давление \(latest.systolic) на \(latest.diastolic), \(latest.zone.title.lowercased())"
    }

    /// Положение маркера на дуге. У давления по шкале зон, у остальных относительно недавнего диапазона.
    private var markerProgress: Double? {
        let data = store.data
        switch selectedKind {
        case .pressure:
            return data.pressure.first.map { PressureScale.progress(systolic: $0.systolic, diastolic: $0.diastolic) }
        case .pulse:
            return relativeProgress(data.pulse)
        case .weight:
            return relativeProgress(data.weight)
        case .glucose:
            return relativeProgress(data.glucose)
        }
    }

    private func relativeProgress(_ reading: MetricReading) -> Double? {
        guard let latest = reading.latest else { return nil }
        guard let low = reading.series.min(), let high = reading.series.max(), high > low else { return 0.5 }
        return min(max((latest - low) / (high - low), 0), 1)
    }
}
