import SwiftUI

/// Размеры компонентов (не отступы и не радиусы).
enum Size {
    // Кнопки и навигация
    static let iconButton: CGFloat = 44
    static let stepperButton: CGFloat = 48
    static let primaryButton: CGFloat = 56
    static let compactButton: CGFloat = 44
    static let navBar: CGFloat = 64
    static let navItem: CGFloat = 52
    static let navIcon: CGFloat = 22
    static let segmentHeight: CGFloat = 44
    static let keypadKey: CGFloat = 52
    static let fieldTile: CGFloat = 76
    static let historyRow: CGFloat = 56
    static let hairline: CGFloat = 1
    /// Обводка активного поля ввода.
    static let focusRing: CGFloat = 2

    // Форма Aura и маркеры
    static let orbPressure: CGFloat = 240
    /// Радиус радиальной тёмной подложки под текстом в центре формы.
    static let orbScrimRadius: CGFloat = 120
    /// Насколько тонкая окружность больше формы.
    static let orbRingInset: CGFloat = 8
    /// Диаметры свечения и белой точки маркера: по умолчанию и на графике давления.
    static let markerGlow: CGFloat = 26
    static let markerDot: CGFloat = 12
    /// Непрозрачность свечения маркера мини-графика (как у `AuraPalette.markerGlow`).
    static let markerGlowOpacity: Double = 0.35
    static let chartMarkerGlow: CGFloat = 24
    static let chartMarkerDot: CGFloat = 10

    // Свечение экрана давления (TopGlow)
    static let glowPressureHeight: CGFloat = 460
    /// Свечение заходит выше начала содержимого, чтобы не было видно верхнего края под статус-баром.
    static let glowBleed: CGFloat = 200
    static let glowBlob: CGFloat = 260
    static let glowBlur: CGFloat = 70
    static let glowFadeStart: Double = 0.3
    static let glowFadeEnd: Double = 1

    // Главный экран (эталон Figma 47:2127)
    /// Верх колонки (кнопка «Давление», «Показатели», бенто) от верха экрана.
    static let homeColumnTop: CGFloat = 447
    /// Верх колонки в состояниях empty и error (вывода нет, пустая зона под ним не нужна).
    static let homeCompactTop: CGFloat = 220
    /// Верх заголовка-вывода от верха экрана.
    static let homeInsightTop: CGFloat = 238
    /// Высота бенто (большая плитка слева и две плитки справа).
    static let bentoHeight: CGFloat = 270
    /// Высота свечения-купола: слой в макете сдвинут вверх (top −251 вместо −168), к ~350 свечение гаснет.
    static let domeHeight: CGFloat = 360
    static let domeOuterWidth: CGFloat = 560
    static let domeOuterHeight: CGFloat = 420
    static let domeOuterCenter: CGFloat = 80
    static let domeCoreWidth: CGFloat = 440
    static let domeCoreHeight: CGFloat = 200
    static let domeCoreCenter: CGFloat = 90
    static let domeOuterBlur: CGFloat = 60
    static let domeCoreBlur: CGFloat = 36
    /// Доли высоты блока (с учётом выноса вверх): до `domeFadeStart` свечение полное, к `domeFadeEnd` его нет.
    /// Ярко до ~y 120 от верха экрана, к ~y 340 почти погасло (зелень доходит до вывода) (блок выше экрана на `glowBleed`).
    static let domeFadeStart: Double = 0.57
    static let domeFadeEnd: Double = 0.97
    /// Непрозрачность свечения (текст вывода лежит ниже купола, на чёрном).
    static let domeOpacity: Double = 0.85
    static let tileHeight: CGFloat = 126
    static let glowButtonHeight: CGFloat = 64
    static let glowButtonIcon: CGFloat = 20
    /// Кнопка «Давление»: кромка 1,5 pt, радиус и непрозрачность зелёного света снизу, слабые участки кромки.
    static let glowButtonRim: CGFloat = 1.5
    static let glowButtonLightRadius: CGFloat = 130
    static let glowButtonLightOpacity: Double = 0.45
    static let glowButtonRimMidOpacity: Double = 0.2
    static let glowButtonRimEndOpacity: Double = 0.6
    /// Зелёная подсветка кромки кнопки профиля по палитре зоны.
    static let profileTintOpacity: Double = 0.55
    static let cardIcon: CGFloat = 20
    /// Радиус свечения в правом нижнем углу плитки бенто и кнопки профиля.
    static let tileGlowRadius: CGFloat = 170
    static let profileGlowRadius: CGFloat = 40
    static let tabBarWidth: CGFloat = 292
    /// Градиент только подкладывается под навигацию: высота навигации (64) + 16.
    static let homeBottomFadeHeight: CGFloat = 80
    /// Радиус тени текста на форме Aura (экран давления).
    static let textShadowRadius: CGFloat = 12
    static let pressedOpacity: Double = 0.8
    static let disabledOpacity: Double = 0.4

    // Карточки и графики
    static let metricIcon: CGFloat = 32
    static let sparklineHeight: CGFloat = 40
    /// Мини-график в тёмной карточке пульса: 141×44 по макету.
    static let sparklineSolidWidth: CGFloat = 141
    static let sparklineSolidHeight: CGFloat = 44
    static let sparklineLine: CGFloat = 2
    static let sparklineDot: CGFloat = 8
    /// Амплитуда мини-графика (доля высоты) и её середина: линия спокойнее, чем на весь размах.
    static let sparklineAmplitude: CGFloat = 0.6
    static let sparklineCenter: CGFloat = 0.5
    static let chartHeight: CGFloat = 190
    static let chartLineUpper: CGFloat = 3
    static let chartLineLower: CGFloat = 2.5
    /// Минимальная высота пустого графика.
    static let chartEmpty: CGFloat = 110
    static let legendLine: CGFloat = 16
    static let statusDot: CGFloat = 8
    static let glassShadow: CGFloat = 24
    /// Высота затухания над нижним краем: фон 100% у самого низа, 0% вверху.
    static let bottomFadeHeight: CGFloat = 180

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

extension Size {
    /// Подложка под статус-бар при прокрутке: запас ниже статус-бара и путь прокрутки, на котором она проявляется.
    static let statusBarFadeExtra: CGFloat = 16
    static let statusBarFadeRamp: CGFloat = 40
}
