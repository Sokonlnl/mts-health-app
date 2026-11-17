import Foundation

/// Данные кольца недели (прежнее представление, остаётся в ViewModel для статистики).
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
        MetricCardModel(kind: kind, valueText: nil, unit: unit, statusText: "Измерений пока нет", tone: .neutral, series: [])
    }
}

/// Пилюля показателя в верхнем ряду.
struct PillModel: Identifiable, Equatable {
    let kind: MetricKind
    let valueText: String
    let state: HealthState
    let isSelected: Bool
    let accessibilityText: String

    var id: String { kind.id }
}

/// Форма и значение главного показателя: определяет палитру, текст в центре и положение маркера.
struct HeroModel: Equatable {
    let kind: MetricKind
    let state: HealthState
    let caption: String
    let valueText: String
    let unit: String
    let statusText: String
    /// Положение маркера на дуге 0...1; `nil`, если значения нет.
    let markerProgress: Double?
    let accessibilityText: String

    var hasValue: Bool { state != .noData }

    /// Ключ анимации `contentSwap`: меняется при смене показателя, значения и состояния.
    var contentKey: String { "\(kind.rawValue)|\(valueText)|\(statusText)" }
}

/// Заголовок-вывод под формой и пояснение. `details == nil`: кнопки «Подробнее» нет.
struct HeadlineModel: Equatable {
    let title: String
    let summary: String
    let details: String?

    var contentKey: String { "\(title)|\(summary)" }
}
