import SwiftUI

/// Размеры компонентов (не отступы и не радиусы).
enum Size {
    static let avatar: CGFloat = 44
    static let iconButton: CGFloat = 44
    static let addButton: CGFloat = 56
    static let ring: CGFloat = 84
    static let ringLine: CGFloat = 8
    static let sparklineWidth: CGFloat = 88
    static let sparklineHeight: CGFloat = 40
    static let sparklineLine: CGFloat = 2
    static let metricIcon: CGFloat = 32
    static let dot: CGFloat = 6
    static let dayCircle: CGFloat = 32
    static let keypadKey: CGFloat = 52
    static let primaryButton: CGFloat = 52
    static let tabBarItem: CGFloat = 52
    static let chartHeight: CGFloat = 220
    static let chartPoint: CGFloat = 60
    static let hairline: CGFloat = 1
    static let fieldTile: CGFloat = 76
    static let skeletonLine: CGFloat = 14
    static let skeletonCard: CGFloat = 112
    static let stateIcon: CGFloat = 56
    static let legendDot: CGFloat = 10
    /// Обводка активного поля ввода.
    static let focusRing: CGFloat = 2
    /// Минимальная высота пустого графика.
    static let chartEmpty: CGFloat = 110
    /// Скелетон: широкая строка, строка значения.
    static let skeletonLineWide: CGFloat = 132
    static let skeletonValue: CGFloat = 32
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
