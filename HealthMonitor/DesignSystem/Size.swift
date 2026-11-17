import SwiftUI

/// Размеры компонентов (не отступы и не радиусы).
enum Size {
    // Кнопки и навигация
    static let iconButton: CGFloat = 44
    static let stepperButton: CGFloat = 48
    static let primaryButton: CGFloat = 56
    static let compactButton: CGFloat = 44
    static let navBar: CGFloat = 64
    static let navAdd: CGFloat = 64
    static let navItem: CGFloat = 52
    static let segmentHeight: CGFloat = 44
    static let keypadKey: CGFloat = 52
    static let fieldTile: CGFloat = 76
    static let historyRow: CGFloat = 56
    static let hairline: CGFloat = 1
    /// Обводка активного поля ввода.
    static let focusRing: CGFloat = 2

    // Форма Aura и дуга зон
    static let orbHome: CGFloat = 280
    /// Диаметр формы внутри дуги зон. Весь блок (дуга и форма) занимает `orbHome` = 280.
    static let orbHomeForm: CGFloat = 232
    static let orbPressure: CGFloat = 240
    /// Насколько тонкая окружность больше формы.
    static let orbRingInset: CGFloat = 8
    static let zoneArcRadius: CGFloat = 132
    static let zoneArcLine: CGFloat = 6
    static let zoneArcSweep: Double = 240
    static let zoneArcStart: Double = 150
    /// Диаметры свечения и белой точки маркера. Радиусы по спецификации: 13 и 6 на дуге, 12 и 5 на графике.
    static let markerGlow: CGFloat = 26
    static let markerDot: CGFloat = 12
    static let chartMarkerGlow: CGFloat = 24
    static let chartMarkerDot: CGFloat = 10

    // Верх главного экрана
    static let pill: CGFloat = 56
    static let pillWidth: CGFloat = 68
    static let pillHeight: CGFloat = 84
    static let glowHomeHeight: CGFloat = 620
    static let glowPressureHeight: CGFloat = 460
    /// Свечение заходит выше начала содержимого, чтобы не было видно верхнего края под статус-баром.
    static let glowBleed: CGFloat = 200
    static let glowBlob: CGFloat = 260
    static let glowBlur: CGFloat = 70

    // Карточки и графики
    static let metricIcon: CGFloat = 32
    static let weekBarWidth: CGFloat = 14
    static let weekBarHeight: CGFloat = 60
    static let weekBarMinimum: CGFloat = 6
    static let sparklineHeight: CGFloat = 40
    static let sparklineLine: CGFloat = 2
    static let sparklineDot: CGFloat = 8
    static let chartHeight: CGFloat = 190
    static let chartLineUpper: CGFloat = 3
    static let chartLineLower: CGFloat = 2.5
    /// Минимальная высота пустого графика.
    static let chartEmpty: CGFloat = 110
    static let legendLine: CGFloat = 16
    static let statusDot: CGFloat = 8
    static let glassShadow: CGFloat = 24

    // Состояния
    static let skeletonLine: CGFloat = 14
    static let skeletonCard: CGFloat = 112
    /// Скелетон: широкая строка, строка значения.
    static let skeletonLineWide: CGFloat = 132
    static let skeletonValue: CGFloat = 32
    static let stateIcon: CGFloat = 56

    // Шторка
    static let dragHandleWidth: CGFloat = 40
    static let dragHandleHeight: CGFloat = 5
    static let sheetDismissDistance: CGFloat = 120
}

/// Минимальные коэффициенты сжатия текста (`minimumScaleFactor`).
enum TextScale {
    /// Крупные значения показателей.
    static let metric: CGFloat = 0.6
    /// Заголовки.
    static let title: CGFloat = 0.7
    /// Подписи переключателей.
    static let compact: CGFloat = 0.8
}
