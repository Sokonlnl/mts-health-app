import SwiftUI

/// Размеры компонентов (не отступы и не радиусы).
enum Size {
    // Кнопки и навигация
    static let iconButton: CGFloat = 44
    static let stepperButton: CGFloat = 48
    static let primaryButton: CGFloat = 56
    static let navBar: CGFloat = 64
    static let navItem: CGFloat = 52
    static let navIcon: CGFloat = 24
    static let segmentHeight: CGFloat = 44
    static let keypadKey: CGFloat = 52
    static let fieldTile: CGFloat = 76
    static let historyRow: CGFloat = 56
    static let hairline: CGFloat = 1
    /// Обводка активного поля ввода.
    static let focusRing: CGFloat = 2

    // Маркеры (график давления)
    static let markerGlow: CGFloat = 26
    static let markerDot: CGFloat = 12
    static let chartMarkerGlow: CGFloat = 24
    static let chartMarkerDot: CGFloat = 10

    // Верхний блок со свечением (главный экран и экран давления, Figma 63:25250)
    /// Высота верхнего блока главного экрана и его компактный вариант (empty, error).
    static let heroHeight: CGFloat = 540
    static let heroCompactHeight: CGFloat = 220
    /// Минимальная высота верхнего блока экрана давления (растёт вместе с текстом).
    static let pressureHeroHeight: CGFloat = 300
    /// Вкладки «Самочувствие / Анализы» (верх 114), вывод (центр блока на y 248, верх 202) и ширина вывода 272.
    static let heroTabsTop: CGFloat = 114
    static let heroInsightTop: CGFloat = 202
    static let insightWidth: CGFloat = 272
    static let tabDot: CGFloat = 5
    static let tabGap: CGFloat = 24
    /// Свечение: пятна у нижнего края блока (ширина, высота, размытие, вынос вниз) и боковое пятно.
    static let domeBlobWidth: CGFloat = 520
    static let domeBlobHeight: CGFloat = 300
    static let domeBlobBlur: CGFloat = 70
    static let domeBlobDrop: CGFloat = 110
    static let domeSideWidth: CGFloat = 260
    static let domeSideHeight: CGFloat = 340
    static let domeSideBlur: CGFloat = 60
    static let domeSideShift: CGFloat = 200
    /// Непрозрачность свечения: основное пятно, боковые пятна, общий вертикальный градиент (верх и низ).
    static let domeOpacity: Double = 0.55
    static let domeSideOpacity: Double = 0.35
    static let domeWashTop: Double = 0.04
    static let domeWashBottom: Double = 0.3

    // Карточки главного экрана
    static let pressureCardHeight: CGFloat = 258
    static let smallCardHeight: CGFloat = 166
    static let cardIconLarge: CGFloat = 24
    static let chipHeight: CGFloat = 35
    static let chipMinWidth: CGFloat = 76
    /// Декоративные пятна в углу карточек (`CornerGlow`): сдвиг за край.
    static let cornerGlowShift: CGFloat = 36
    /// Сердце в большой карточке (`HeartGlow`, Figma heart.svg 330×296 вместе с полями под размытие, сердце 264×230):
    /// размытие слоёв и вынос рамки за правый нижний угол карточки.
    static let heartFrame = CGSize(width: 330, height: 296)
    static let heartBlur: CGFloat = 16.4
    static let heartInnerBlur: CGFloat = 15.83
    /// Внутренние чёрные слои сердца: наложение (overlay) 67% и жёсткий свет (hard light) 20%.
    static let heartOverlayOpacity: Double = 0.67
    static let heartHardLightOpacity: Double = 0.2
    static let heartOffsetX: CGFloat = 30
    static let heartOffsetY: CGFloat = 52
    /// Радиус радиального градиента сердца (в единицах viewBox) и центр (доли рамки).
    static let heartGradientRadius: CGFloat = 125
    static let heartGradientCenter = UnitPoint(x: 150.58 / 330, y: 182.42 / 296)
    /// Кнопка ГигаЧата: ширина 330 при колонке 358.
    static let glowButtonWidth: CGFloat = 330
    static let glowButtonHeight: CGFloat = 64
    static let glowButtonIcon: CGFloat = 20
    /// Кромка кнопки с зелёным свечением 1,5 pt, радиус и непрозрачность света снизу, слабые участки кромки.
    static let glowButtonRim: CGFloat = 1.5
    static let glowButtonLightRadius: CGFloat = 130
    static let glowButtonLightOpacity: Double = 0.45
    static let glowButtonRimMidOpacity: Double = 0.2
    static let glowButtonRimEndOpacity: Double = 0.6
    /// Кромка малой карточки 0,8 pt.
    static let flatRim: CGFloat = 0.8
    /// Отсвет кнопки профиля по палитре зоны.
    static let profileTintOpacity: Double = 0.55
    /// Радиус свечения в правом нижнем углу плитки и кнопки профиля.
    static let tileGlowRadius: CGFloat = 170
    static let profileGlowRadius: CGFloat = 40

    // Мини-шкалы малых карточек
    /// Три плашки шкалы веса (сверху вниз): жёлтая, зелёная, жёлтая, зазор между ними и линия-маркер.
    static let gaugeBandWarning: CGFloat = 10
    static let gaugeBandGood: CGFloat = 30
    static let gaugeBandGap: CGFloat = 2
    static let gaugeMarker: CGFloat = 2
    /// Дуга шкалы глюкозы: диаметр окружности, толщина, доля подсвеченного участка и маркер.
    static let gaugeArcDiameter: CGFloat = 120
    static let gaugeArcLine: CGFloat = 8
    static let gaugeArcLitStart: Double = 0.3
    static let gaugeArcLitEnd: Double = 0.7
    static let gaugeDot: CGFloat = 12

    // Совет и колода
    static let adviceHeight: CGFloat = 239
    static let adviceAvatar: CGFloat = 41
    /// Карточки колоды позади: сдвиг вниз и сужение с каждой стороны на шаг.
    static let adviceStackStep: CGFloat = 10
    static let adviceStackInset: CGFloat = 14
    static let adviceGlowSize: CGFloat = 150
    static let adviceGlowBlur: CGFloat = 50
    static let adviceGlowOpacity: Double = 0.35

    // Прочее
    static let tabBarWidth: CGFloat = 292
    /// Градиент только подкладывается под навигацию: высота навигации (64) + 16.
    static let homeBottomFadeHeight: CGFloat = 80
    /// Подсказка «Скоро» над плавающей навигацией.
    static let toastBottom: CGFloat = 96
    static let pressedOpacity: Double = 0.8
    static let disabledOpacity: Double = 0.4

    // Карточки и графики
    static let metricIcon: CGFloat = 32
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

    // Подложка под статус-бар при прокрутке: запас ниже статус-бара и путь прокрутки, на котором она проявляется.
    static let statusBarFadeExtra: CGFloat = 16
    static let statusBarFadeRamp: CGFloat = 40
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
