import SwiftUI
import UIKit

/// Текстовый стиль: шрифт и межбуквенный интервал.
struct AppTextStyle {
    let size: CGFloat
    let weight: Font.Weight
    let tracking: CGFloat
    let textStyle: UIFont.TextStyle

    /// Шрифт с учётом Dynamic Type (размер масштабируется относительно textStyle).
    var font: Font {
        let scaled = UIFontMetrics(forTextStyle: textStyle).scaledValue(for: size)
        return .system(size: scaled, weight: weight)
    }
}

/// Типографика из docs/DESIGN.md (SF Pro).
enum AppTypography {
    static let metricHero = AppTextStyle(size: 48, weight: .bold, tracking: -1.5, textStyle: .largeTitle)
    static let metricCard = AppTextStyle(size: 32, weight: .bold, tracking: -0.8, textStyle: .largeTitle)
    static let title = AppTextStyle(size: 24, weight: .bold, tracking: 0, textStyle: .title1)
    static let headline = AppTextStyle(size: 18, weight: .semibold, tracking: 0, textStyle: .headline)
    static let bodyStrong = AppTextStyle(size: 15, weight: .semibold, tracking: 0, textStyle: .body)
    static let body = AppTextStyle(size: 15, weight: .regular, tracking: 0, textStyle: .body)
    static let label = AppTextStyle(size: 14, weight: .medium, tracking: 0, textStyle: .subheadline)
    static let caption = AppTextStyle(size: 12, weight: .regular, tracking: 0, textStyle: .caption1)
    static let captionStrong = AppTextStyle(size: 13, weight: .semibold, tracking: 0, textStyle: .caption1)
}

extension AppTextStyle {
    static let metricHero = AppTypography.metricHero
    static let metricCard = AppTypography.metricCard
    static let title = AppTypography.title
    static let headline = AppTypography.headline
    static let bodyStrong = AppTypography.bodyStrong
    static let body = AppTypography.body
    static let label = AppTypography.label
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
        ("metricHero 48/700", .metricHero), ("metricCard 32/700", .metricCard),
        ("title 24/700", .title), ("headline 18/600", .headline),
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
