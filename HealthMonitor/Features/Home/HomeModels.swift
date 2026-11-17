import Foundation

/// Данные карточки показателя (и плитки бенто: раскладку выбирает вызов `MetricCard`).
/// `statusText == nil`: статуса нет (плитки пульса и веса).
struct MetricCardModel: Identifiable, Equatable {
    let kind: MetricKind
    let valueText: String?
    let unit: String
    let statusText: String?
    let tone: StatusTone
    let series: [Double]

    var id: String { kind.id }

    /// Поверхность карточки: пульс на главном экране тёмный (`.solid`), остальные стекло. Единственный источник.
    var surface: MetricCard.Surface { kind == .pulse ? .solid : .glass }

    /// Стиль мини-графика: у пульса маркер на последней точке. Единственный источник.
    var sparklineStyle: Sparkline.Style { kind == .pulse ? .marker : .line }

    /// Подпись справа от значения: без значения единица и статус одной строкой («ммоль/л · измерений пока нет»).
    var valueCaption: String {
        guard valueText == nil, let statusText else { return unit }
        return unit + " · " + statusText.lowercased()
    }

    static func empty(_ kind: MetricKind, unit: String) -> MetricCardModel {
        MetricCardModel(
            kind: kind, valueText: nil, unit: unit, statusText: AppFormat.noMeasurementsYet, tone: .neutral, series: []
        )
    }
}

/// Заголовок-вывод в зоне свечения и пояснение. `details == nil`: кнопки «Подробнее» нет.
struct HeadlineModel: Equatable {
    let title: String
    let summary: String
    let details: String?

    var contentKey: String { "\(title)|\(summary)" }
}
