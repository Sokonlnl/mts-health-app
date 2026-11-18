import SwiftUI
import UIKit

/// Текстовый стиль: шрифт, межбуквенный интервал, интерлиньяж, поведение при Dynamic Type.
struct AppTextStyle {
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design
    let tracking: CGFloat
    /// Добавка к высоте строки (отрицательная сжимает строки, как `line-height` меньше кегля в макете).
    let lineSpacing: CGFloat
    let textStyle: UIFont.TextStyle
    /// Верхний предел роста размера при Dynamic Type (во сколько раз). Ограничены только крупные числа.
    let maxScale: CGFloat
    /// Иконка SF Symbols: всегда системный шрифт (SB Sans Display символов не содержит).
    let isSymbol: Bool

    init(
        size: CGFloat,
        weight: Font.Weight,
        design: Font.Design = .default,
        tracking: CGFloat = 0,
        lineSpacing: CGFloat = 0,
        textStyle: UIFont.TextStyle,
        maxScale: CGFloat = .greatestFiniteMagnitude,
        isSymbol: Bool = false
    ) {
        self.size = size
        self.weight = weight
        self.design = design
        self.tracking = tracking
        self.lineSpacing = lineSpacing
        self.textStyle = textStyle
        self.maxScale = maxScale
        self.isSymbol = isSymbol
    }

    /// Тот же размер и жирность, но для иконки SF Symbols (системный шрифт, SB Sans Display символов не содержит).
    var asSymbol: AppTextStyle {
        AppTextStyle(
            size: size, weight: weight, design: design, tracking: tracking, lineSpacing: lineSpacing,
            textStyle: textStyle, maxScale: maxScale, isSymbol: true
        )
    }

    /// Шрифт для заданной категории Dynamic Type (размер масштабируется относительно textStyle, не выше maxScale).
    /// Снаружи используй только `.textStyle(_:)`: он берёт категорию из окружения и перерисовывается при её смене.
    fileprivate func font(for category: UIContentSizeCategory) -> Font {
        let traits = UITraitCollection(preferredContentSizeCategory: category)
        let scaled = UIFontMetrics(forTextStyle: textStyle).scaledValue(for: size, compatibleWith: traits)
        let fitted = min(scaled, size * maxScale)
        // SB Sans Display (только Regular): жирность и дизайн системного шрифта не переносятся, жирность не синтезируется.
        if !isSymbol, let name = AppFont.name {
            return .custom(name, fixedSize: fitted)
        }
        return .system(size: fitted, weight: weight, design: design)
    }
}

/// Типографика из docs/DESIGN.md. Весь текст SB Sans Display (Regular), фолбэк при отсутствии файла: SF Pro и SF Pro Rounded.
enum AppTypography {
    /// Крупное значение показателя в верхнем блоке страницы показателя (Figma 86:123): 84,4 pt.
    static let heroValue = AppTextStyle(size: 84.4, weight: .regular, tracking: -2.53, textStyle: .largeTitle, maxScale: 1.0)
    static let metricCard = AppTextStyle(
        size: 44, weight: .bold, design: .rounded, tracking: -1.2, textStyle: .largeTitle, maxScale: 1.4
    )
    static let metricCardSmall = AppTextStyle(
        size: 38, weight: .bold, design: .rounded, tracking: -1.2, textStyle: .largeTitle, maxScale: 1.4
    )
    static let title = AppTextStyle(size: 24, weight: .bold, design: .rounded, textStyle: .title1)
    static let heroHeadline = AppTextStyle(size: 22, weight: .bold, design: .rounded, textStyle: .title2)
    static let headline = AppTextStyle(size: 18, weight: .semibold, design: .rounded, textStyle: .headline)
    static let headlineCompact = AppTextStyle(size: 17, weight: .semibold, design: .rounded, textStyle: .headline)
    static let bodyStrong = AppTextStyle(size: 15, weight: .semibold, textStyle: .body)
    static let body = AppTextStyle(size: 15, weight: .regular, textStyle: .body)
    static let label = AppTextStyle(size: 14, weight: .medium, textStyle: .subheadline)
    /// Подпись большой карточки и вкладки в верхнем блоке (16).
    static let cardLabel = AppTextStyle(size: 16, weight: .regular, tracking: -0.3, textStyle: .callout)
    /// Подпись малой карточки (14).
    static let smallCardLabel = AppTextStyle(size: 14, weight: .regular, tracking: -0.28, textStyle: .subheadline)
    static let smallCardValue = AppTextStyle(size: 24, weight: .regular, tracking: -0.5, textStyle: .title2, maxScale: 1.3)
    static let unitLabel = AppTextStyle(size: 13, weight: .regular, textStyle: .caption1)
    static let chipLabel = AppTextStyle(size: 14, weight: .semibold, textStyle: .subheadline)
    /// Вывод в верхнем блоке: 34,6 pt при высоте строки 31.
    static let insightTitle = AppTextStyle(
        size: 34.6, weight: .regular, tracking: -0.47, lineSpacing: -3.6, textStyle: .largeTitle, maxScale: 1.4
    )
    static let insightSummary = AppTextStyle(size: 14, weight: .regular, textStyle: .subheadline)
    /// Заголовок блока советов: 56,6 pt при высоте строки 54.
    static let sectionTitle = AppTextStyle(
        size: 56.6, weight: .regular, tracking: -4.5, lineSpacing: -2.6, textStyle: .largeTitle, maxScale: 1.2
    )
    static let adviceTitle = AppTextStyle(size: 23, weight: .regular, tracking: -0.35, lineSpacing: 4, textStyle: .title2)
    static let adviceBody = AppTextStyle(size: 14, weight: .regular, lineSpacing: 2, textStyle: .subheadline)
    static let glowButtonTitle = AppTextStyle(size: 16, weight: .medium, textStyle: .body)
    static let caption = AppTextStyle(size: 12, weight: .regular, textStyle: .caption1)
    static let captionStrong = AppTextStyle(size: 13, weight: .semibold, textStyle: .caption1)
    /// Иконка 24 pt (SF Symbols): размер не растёт с Dynamic Type.
    static let icon = AppTextStyle(size: 24, weight: .regular, textStyle: .title1, maxScale: 1, isSymbol: true)
    /// Иконка в заголовке карточки 18 pt: размер не растёт с Dynamic Type.
    static let cardIcon = AppTextStyle(size: 18, weight: .regular, textStyle: .title3, maxScale: 1, isSymbol: true)
}

extension AppTextStyle {
    static let heroValue = AppTypography.heroValue
    static let metricCard = AppTypography.metricCard
    static let metricCardSmall = AppTypography.metricCardSmall
    static let title = AppTypography.title
    static let heroHeadline = AppTypography.heroHeadline
    static let headline = AppTypography.headline
    static let headlineCompact = AppTypography.headlineCompact
    static let bodyStrong = AppTypography.bodyStrong
    static let body = AppTypography.body
    static let label = AppTypography.label
    static let cardLabel = AppTypography.cardLabel
    static let smallCardLabel = AppTypography.smallCardLabel
    static let smallCardValue = AppTypography.smallCardValue
    static let unitLabel = AppTypography.unitLabel
    static let chipLabel = AppTypography.chipLabel
    static let insightTitle = AppTypography.insightTitle
    static let insightSummary = AppTypography.insightSummary
    static let sectionTitle = AppTypography.sectionTitle
    static let adviceTitle = AppTypography.adviceTitle
    static let adviceBody = AppTypography.adviceBody
    static let glowButtonTitle = AppTypography.glowButtonTitle
    static let caption = AppTypography.caption
    static let captionStrong = AppTypography.captionStrong
    static let icon = AppTypography.icon
    static let cardIcon = AppTypography.cardIcon
}

/// Применяет стиль с учётом `dynamicTypeSize` из окружения: при смене размера текста
/// в настройках (или в аудите доступности) шрифт пересчитывается. Найдено аудитом доступности (QA-010).
private struct TextStyleModifier: ViewModifier {
    let style: AppTextStyle
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        content
            .font(style.font(for: Self.category(for: dynamicTypeSize)))
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
    }

    /// Явное соответствие размеров SwiftUI категориям UIKit (без опоры на конвертер SDK).
    private static func category(for size: DynamicTypeSize) -> UIContentSizeCategory {
        categories[size] ?? .large
    }

    /// Таблица вместо switch: SwiftLint ограничивает цикломатическую сложность функции 10.
    private static let categories: [DynamicTypeSize: UIContentSizeCategory] = [
        .xSmall: .extraSmall,
        .small: .small,
        .medium: .medium,
        .large: .large,
        .xLarge: .extraLarge,
        .xxLarge: .extraExtraLarge,
        .xxxLarge: .extraExtraExtraLarge,
        .accessibility1: .accessibilityMedium,
        .accessibility2: .accessibilityLarge,
        .accessibility3: .accessibilityExtraLarge,
        .accessibility4: .accessibilityExtraExtraLarge,
        .accessibility5: .accessibilityExtraExtraExtraLarge
    ]
}

extension View {
    /// Применяет токен типографики: `Text("...").textStyle(.title)`.
    func textStyle(_ style: AppTextStyle) -> some View {
        modifier(TextStyleModifier(style: style))
    }
}

#Preview("Typography") {
    let styles: [(String, AppTextStyle)] = [
        ("heroValue 84.4/400", .heroValue),
        ("metricCard 44/700", .metricCard), ("metricCardSmall 38/700", .metricCardSmall),
        ("title 24/700", .title), ("heroHeadline 22/700", .heroHeadline),
        ("headline 18/600", .headline), ("headlineCompact 17/600", .headlineCompact),
        ("body 15/600", .bodyStrong), ("body 15/400", .body),
        ("cardLabel 16", .cardLabel), ("label 14/500", .label), ("smallCardValue 24", .smallCardValue),
        ("chipLabel 14/600", .chipLabel), ("caption 12/400", .caption),
        ("caption 13/600", .captionStrong), ("adviceTitle 23", .adviceTitle)
    ]
    return VStack(alignment: .leading, spacing: 8) {
        ForEach(styles, id: \.0) { item in
            Text(item.0).textStyle(item.1).foregroundStyle(AppColor.textPrimary)
        }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColor.background)
}
