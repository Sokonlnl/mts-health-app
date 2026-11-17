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

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SkeletonBlock(width: Size.metricIcon * 3)
            SkeletonBlock(height: Size.skeletonValue)
            SkeletonBlock(width: Size.skeletonLineWide)
        }
        .frame(maxWidth: .infinity, minHeight: Size.skeletonCard, alignment: .leading)
        .glassCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Загрузка")
        .accessibilityIdentifier(identifier)
    }
}

/// Скелетон плитки (loading).
struct SkeletonTile: View {
    var body: some View {
        VStack(spacing: Spacing.s) {
            SkeletonBlock(width: Size.metricIcon * 1.5)
            SkeletonBlock(width: Size.metricIcon * 2, height: Size.skeletonValue)
        }
        .padding(.horizontal, Spacing.s)
        .padding(.vertical, Spacing.m)
        .glassTile()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Загрузка")
        .accessibilityIdentifier("skeleton-tile")
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

/// Скелетон кнопки «Давление» (loading).
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

/// Тёмная нейтральная форма без вращения для loading-состояния экрана.
struct SkeletonOrb: View {
    let diameter: CGFloat

    var body: some View {
        AuraOrb(palette: .noData, diameter: diameter, isAnimated: false) {
            VStack(spacing: Spacing.s) {
                SkeletonBlock(width: Size.skeletonLineWide, height: Size.skeletonValue)
                SkeletonBlock(width: Size.skeletonLineWide / 2)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Загрузка")
    }
}

#Preview("SkeletonTile, вывод, кнопка") {
    VStack(spacing: Spacing.columnGap) {
        SkeletonHeadline()
        SkeletonButton()
        BentoGrid {
            SkeletonTile()
        } side: {
            SkeletonTile()
            SkeletonTile()
        }
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.homeBackground)
}

#Preview("SkeletonCard") {
    SkeletonCard()
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}

#Preview("SkeletonList + форма") {
    VStack(spacing: Spacing.l) {
        SkeletonOrb(diameter: Size.orbPressure)
        SkeletonList(count: 2)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
