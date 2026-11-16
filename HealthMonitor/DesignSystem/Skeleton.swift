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
            SkeletonBlock(height: Size.skeletonValue)
            SkeletonBlock(width: Size.skeletonLineWide)
        }
        .frame(maxWidth: .infinity, minHeight: Size.skeletonCard, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Загрузка")
        .accessibilityIdentifier(identifier)
    }
}

/// Список скелетонов карточек (loading-состояние экрана). Первая карточка получает идентификатор
/// `loading-state`, остальные `skeleton-card`.
struct SkeletonList: View {
    var count = 3
    var firstIdentifier = "loading-state"

    var body: some View {
        VStack(spacing: Spacing.l) {
            ForEach(0..<count, id: \.self) { index in
                SkeletonCard(identifier: index == 0 ? firstIdentifier : "skeleton-card")
            }
        }
    }
}

#Preview("SkeletonCard") {
    SkeletonCard()
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}

#Preview("SkeletonList") {
    SkeletonList()
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
