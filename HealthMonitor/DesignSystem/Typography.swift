import SwiftUI
import UIKit

/// Текстовый стиль: шрифт, межбуквенный интервал, поведение при Dynamic Type.
struct AppTextStyle {
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design
    let tracking: CGFloat
    let textStyle: UIFont.TextStyle
    /// Верхний предел роста размера при Dynamic Type (во сколько раз). Ограничены только крупные числа.
    let maxScale: CGFloat

    init(
        size: CGFloat,
        weight: Font.Weight,
        design: Font.Design = .default,
        tracking: CGFloat = 0,
        textStyle: UIFont.TextStyle,
        maxScale: CGFloat = .greatestFiniteMagnitude
    ) {
        self.size = size
        self.weight = weight
        self.design = design
        self.tracking = tracking
        self.textStyle = textStyle
        self.maxScale = maxScale
    }

    /// Шрифт для заданной категории Dynamic Type (размер масштабируется относительно textStyle, не выше maxScale).
    /// Снаружи используй только `.textStyle(_:)`: он берёт категорию из окружения и перерисовывается при её смене.
    fileprivate func font(for category: UIContentSizeCategory) -> Font {
        let traits = UITraitCollection(preferredContentSizeCategory: category)
        let scaled = UIFontMetrics(forTextStyle: textStyle).scaledValue(for: size, compatibleWith: traits)
        return .system(size: min(scaled, size * maxScale), weight: weight, design: design)
    }
}

/// Типографика из docs/DESIGN.md. На макете Inter и Space Grotesk, в iOS: SF Pro и SF Pro Rounded.
enum AppTypography {
    static let heroValue = AppTextStyle(size: 68, weight: .ultraLight, tracking: -2, textStyle: .largeTitle, maxScale: 1.2)
    static let heroValueCompact = AppTextStyle(size: 56, weight: .ultraLight, tracking: -2, textStyle: .largeTitle, maxScale: 1.2)
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
    static let tileLabel = AppTextStyle(size: 14, weight: .regular, tracking: -0.28, textStyle: .subheadline)
    static let tileValue = AppTextStyle(size: 38, weight: .light, tracking: -1.8, textStyle: .largeTitle, maxScale: 1.3)
    static let insightTitle = AppTextStyle(size: 22, weight: .regular, tracking: -0.3, textStyle: .title2)
    static let insightSummary = AppTextStyle(size: 14, weight: .regular, textStyle: .subheadline)
    static let tileUnit = AppTextStyle(size: 13, weight: .regular, textStyle: .caption1)
    static let cardValue = AppTextStyle(size: 38, weight: .regular, tracking: -1.2, textStyle: .largeTitle, maxScale: 1.3)
    static let glowButtonTitle = AppTextStyle(size: 16, weight: .medium, textStyle: .body)
    static let caption = AppTextStyle(size: 12, weight: .regular, textStyle: .caption1)
    static let captionStrong = AppTextStyle(size: 13, weight: .semibold, textStyle: .caption1)
}

extension AppTextStyle {
    static let heroValue = AppTypography.heroValue
    static let heroValueCompact = AppTypography.heroValueCompact
    static let metricCard = AppTypography.metricCard
    static let metricCardSmall = AppTypography.metricCardSmall
    static let title = AppTypography.title
    static let heroHeadline = AppTypography.heroHeadline
    static let headline = AppTypography.headline
    static let headlineCompact = AppTypography.headlineCompact
    static let bodyStrong = AppTypography.bodyStrong
    static let body = AppTypography.body
    static let label = AppTypography.label
    static let tileLabel = AppTypography.tileLabel
    static let tileValue = AppTypography.tileValue
    static let insightTitle = AppTypography.insightTitle
    static let insightSummary = AppTypography.insightSummary
    static let tileUnit = AppTypography.tileUnit
    static let cardValue = AppTypography.cardValue
    static let glowButtonTitle = AppTypography.glowButtonTitle
    static let caption = AppTypography.caption
    static let captionStrong = AppTypography.captionStrong
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
        ("heroValue 68/200", .heroValue), ("heroValueCompact 56/200", .heroValueCompact),
        ("metricCard 44/700", .metricCard), ("metricCardSmall 38/700", .metricCardSmall),
        ("title 24/700", .title), ("heroHeadline 22/700", .heroHeadline),
        ("headline 18/600", .headline), ("headlineCompact 17/600", .headlineCompact),
        ("body 15/600", .bodyStrong), ("body 15/400", .body),
        ("label 14/500", .label), ("caption 12/400", .caption),
        ("caption 13/600", .captionStrong)
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
