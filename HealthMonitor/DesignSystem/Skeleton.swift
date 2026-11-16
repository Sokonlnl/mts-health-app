import SwiftUI

/// Серый блок-скелетон. Без анимации, чтобы не мешать UI-тестам.
struct SkeletonBlock: View {
    var width: CGFloat?
    var height: CGFloat = Size.skeletonLine

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
            .fill(AppColor.fill)
            .frame(width: width, height: height)
    }
}

/// Скелетон карточки (loading-состояние).
struct SkeletonCard: View {
    var identifier = "skeleton-card"

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SkeletonBlock(width: Size.sparklineWidth)
            SkeletonBlock(height: Size.metricIcon)
            SkeletonBlock(width: Size.sparklineWidth * 1.5)
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, minHeight: Size.skeletonCard, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Загрузка")
        .accessibilityIdentifier(identifier)
    }
}

#Preview("Skeleton") {
    VStack(spacing: Spacing.l) {
        SkeletonCard()
        SkeletonCard()
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
