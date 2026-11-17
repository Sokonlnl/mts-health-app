import Foundation

/// Данные карточки показателя.
struct MetricCardModel: Identifiable, Equatable {
    let kind: MetricKind
    let valueText: String?
    let unit: String
    let statusText: String
    let tone: StatusTone
    let series: [Double]
    /// Мини-график под статусом (пульс). У веса и пустых карточек графика нет, у глюкозы пунктир пустого графика.
    var showsSparkline = true

    var id: String { kind.id }

    static func empty(_ kind: MetricKind, unit: String) -> MetricCardModel {
        MetricCardModel(kind: kind, valueText: nil, unit: unit, statusText: "Измерений пока нет", tone: .neutral, series: [], showsSparkline: kind != .weight)
    }
}

/// Заголовок-вывод в зоне свечения и пояснение. `details == nil`: кнопки «Подробнее» нет.
struct HeadlineModel: Equatable {
    let title: String
    let summary: String
    let details: String?

    var contentKey: String { "\(title)|\(summary)" }
}
