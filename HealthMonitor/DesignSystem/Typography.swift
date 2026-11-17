import SwiftUI
import UIKit

/// Текстовый стиль: шрифт, межбуквенный интервал, поведение при Dynamic Type.
struct AppTextStyle {
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design
    let tracking: CGFloat
    let textStyle: UIFont.TextStyle
    /// Верхний предел роста размера при Dynamic Type (во сколько раз).
    let maxScale: CGFloat

    init(
        size: CGFloat,
        weight: Font.Weight,
        design: Font.Design = .default,
        tracking: CGFloat = 0,
        textStyle: UIFont.TextStyle,
        maxScale: CGFloat = 2
    ) {
        self.size = size
        self.weight = weight
        self.design = design
        self.tracking = tracking
        self.textStyle = textStyle
        self.maxScale = maxScale
    }

    /// Шрифт с учётом Dynamic Type (размер масштабируется относительно textStyle).
    var font: Font {
        let scaled = UIFontMetrics(forTextStyle: textStyle).scaledValue(for: size)
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
    static let tileLabel = AppTextStyle(size: 14, weight: .regular, tracking: -0.28, textStyle: .subheadline, maxScale: 1.3)
    static let tileValue = AppTextStyle(size: 28, weight: .light, tracking: -1.8, textStyle: .title1, maxScale: 1.3)
    static let tileUnit = AppTextStyle(size: 13, weight: .regular, textStyle: .caption1, maxScale: 1.3)
    static let cardValue = AppTextStyle(size: 38, weight: .regular, tracking: -1.2, textStyle: .largeTitle, maxScale: 1.3)
    static let glowButtonTitle = AppTextStyle(size: 16, weight: .medium, textStyle: .body, maxScale: 1.3)
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
    static let tileUnit = AppTypography.tileUnit
    static let cardValue = AppTypography.cardValue
    static let glowButtonTitle = AppTypography.glowButtonTitle
    static let caption = AppTypography.caption
    static let captionStrong = AppTypography.captionStrong
}

extension View {
    /// Применяет токен типографики: `Text("...").textStyle(.title)`.
    func textStyle(_ style: AppTextStyle) -> some View {
        font(style.font).tracking(style.tracking)
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
