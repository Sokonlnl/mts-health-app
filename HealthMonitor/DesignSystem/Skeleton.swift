import SwiftUI

/// Стеклянный блок-скелетон. Без анимации, чтобы не мешать UI-тестам.
struct SkeletonBlock: View {
    var width: CGFloat?
    var height: CGFloat = Size.skeletonLine

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
            .fill(AppColor.fillSelected)
            .frame(width: width, height: height)
    }
}

/// Скелетон карточки (loading-состояние).
struct SkeletonCard: View {
    var identifier = "skeleton-card"
    var minHeight = Size.skeletonCard
    var radius = Radius.tile

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SkeletonBlock(width: Size.metricIcon * 3)
            SkeletonBlock(height: Size.skeletonValue)
            SkeletonBlock(width: Size.skeletonLineWide)
        }
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
        .glassCard(radius: radius)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Загрузка")
        .accessibilityIdentifier(identifier)
    }
}

/// Скелетон вывода («Всё спокойно» и пояснение) в зоне свечения. Первый скелетон экрана: `loading-state`.
struct SkeletonHeadline: View {
    var identifier = "loading-state"

    var body: some View {
        VStack(spacing: Spacing.headlineGap) {
            SkeletonBlock(width: Size.skeletonLineWide, height: Size.skeletonValue)
            SkeletonBlock(width: Size.skeletonLineWide * 2)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Загрузка")
        .accessibilityIdentifier(identifier)
    }
}

/// Скелетон кнопки ГигаЧата (loading).
struct SkeletonButton: View {
    var body: some View {
        SkeletonBlock(height: Size.glowButtonHeight)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Загрузка")
            .accessibilityIdentifier("skeleton-button")
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

#Preview("Скелетоны: вывод, карточки, кнопка") {
    VStack(spacing: Spacing.columnGap) {
        SkeletonHeadline()
        SkeletonCard(identifier: "skeleton-card", minHeight: Size.pressureCardHeight, radius: Radius.heroCard)
        HStack(spacing: Spacing.tileGap) {
            SkeletonCard(minHeight: Size.smallCardHeight, radius: Radius.tile)
            SkeletonCard(minHeight: Size.smallCardHeight, radius: Radius.tile)
        }
        SkeletonButton()
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("SkeletonCard") {
    SkeletonCard()
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}

#Preview("SkeletonList") {
    SkeletonList(count: 2)
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
