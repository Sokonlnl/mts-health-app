import Foundation

/// Данные карточки показателя главного экрана (большая карточка давления и малые карточки веса и глюкозы).
/// `valueText == nil`: данных нет (прочерк, подпись «единица · измерений пока нет»).
struct MetricCardModel: Identifiable, Equatable {
    let kind: MetricKind
    let valueText: String?
    /// Единица измерения без добавок.
    let unit: String
    /// Статус зоны (только у давления, без данных «Нет данных»). У веса и глюкозы нет.
    let statusText: String?
    let tone: StatusTone
    /// Положение маркера на мини-шкале 0...1. `nil`: нет значения или шкалы.
    let gaugePosition: Double?
    /// Ритм сердцебиения декоративного сердца в карточке давления (по пульсу). `nil`: сердце неподвижно.
    var rhythm: HeartbeatRhythm?

    var id: String { kind.id }

    /// Мини-шкала: полосы у веса, дуга у глюкозы, у давления шкалы нет. Единственный источник.
    var gauge: MetricGauge.Style? {
        switch kind {
        case .weight: return .bands
        case .glucose: return .arc
        case .pressure, .pulse: return nil
        }
    }

    var isPlaceholder: Bool { valueText == nil }

    /// Значение для показа: без данных прочерк («–/–» у давления).
    var displayValue: String {
        if let valueText { return valueText }
        return kind == .pressure ? AppFormat.emptyPressureValue : AppFormat.dash
    }

    /// Подпись справа от значения: без данных и без статуса единица и «измерений пока нет» одной строкой.
    var captionText: String {
        guard valueText == nil, statusText == nil else { return unit }
        return AppFormat.unitCaption(unit, status: AppFormat.noMeasurementsYet)
    }

    var accessibilityText: String {
        AppFormat.metricAccessibility(title: kind.title, value: valueText, unit: unit, status: statusText)
    }
}

/// Заголовок-вывод в верхнем блоке и пояснение. `details == nil`: кнопки «Подробнее» нет.
struct HeadlineModel: Equatable {
    let title: String
    let summary: String
    let details: String?

    var contentKey: String { "\(title)|\(summary)" }
}

/// Совет для карточки: тексты и автор приходят готовыми.
struct AdviceCardModel: Identifiable, Equatable {
    let id: String
    let title: String
    let text: String
    let author: String
    let role: String
    let iconName: String
    /// Оговорка при повышенном и высоком давлении.
    let disclaimer: String?
}

/// Вкладка верхнего блока («Самочувствие», «Анализы»).
struct HomeTab: Identifiable, Hashable {
    let id: String
    let title: String
}
