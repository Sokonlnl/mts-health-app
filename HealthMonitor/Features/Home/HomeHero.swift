import SwiftUI

/// Форма Aura 280 pt с дугой зон 240° и маркером. Состояние показателя определяет палитру.
struct HomeHeroOrb: View {
    let hero: HeroModel

    var body: some View {
        ZStack {
            ZoneArcView(
                segments: hero.kind == .pressure ? ZoneArcView.pressureSegments : ZoneArcView.neutralSegments,
                progress: hero.markerProgress,
                markerGlow: hero.state.palette.markerGlow
            )
            AuraOrb(palette: hero.state.palette, diameter: Size.orbHomeForm) {
                AuraOrbCenter(
                    caption: hero.caption,
                    value: hero.valueText,
                    unit: hero.unit,
                    statusText: hero.statusText,
                    tone: hero.state.tone,
                    isPlaceholder: !hero.hasValue,
                    accessibilityText: hero.accessibilityText,
                    valueIdentifier: "home-hero-value",
                    contentKey: hero.contentKey
                )
            }
        }
        .frame(width: Size.orbHome, height: Size.orbHome)
        .frame(maxWidth: .infinity)
    }
}

/// Заголовок-вывод под формой, пояснение и «Подробнее».
struct HomeHeadline: View {
    let headline: HeadlineModel
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: Spacing.s) {
            VStack(spacing: Spacing.xs) {
                Text(headline.title)
                    .textStyle(.heroHeadline)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text(headline.summary)
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .contentSwap(headline.contentKey)
            if let details = headline.details {
                if isExpanded {
                    Text(details)
                        .textStyle(.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("insight-details")
                }
                toggle
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.s)
    }

    private var toggle: some View {
        Button(action: onToggle) {
            HStack(spacing: Spacing.xs) {
                Text(isExpanded ? "Свернуть" : "Подробнее")
                    .textStyle(.bodyStrong)
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(AppTextStyle.captionStrong.font)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(AppColor.textPrimary)
            .frame(minWidth: Spacing.minTapTarget, minHeight: Spacing.minTapTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("insight-toggle")
    }
}

private enum HeroSamples {
    static func hero(_ state: HealthState, value: String, status: String) -> HeroModel {
        HeroModel(
            kind: .pressure, state: state, caption: "Давление", valueText: value, unit: AppUnit.pressure,
            statusText: status, markerProgress: state == .noData ? nil : 0.4, accessibilityText: "Давление \(value), \(status)"
        )
    }
}

private struct HeroPreview: View {
    let hero: HeroModel

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            VStack {
                HomeHeroOrb(hero: hero)
                HomeHeadline(
                    headline: HeadlineModel(title: "Всё спокойно", summary: "Давление в норме 7 из 7 дней.", details: "Подробности"),
                    isExpanded: false,
                    onToggle: {}
                )
            }
        }
    }
}

#Preview("HomeHero: норма") {
    HeroPreview(hero: HeroSamples.hero(.normal, value: "122/79", status: "Норма"))
}

#Preview("HomeHero: повышенное") {
    HeroPreview(hero: HeroSamples.hero(.elevated, value: "134/86", status: "Повышенное"))
}

#Preview("HomeHero: высокое") {
    HeroPreview(hero: HeroSamples.hero(.high, value: "148/94", status: "Высокое"))
}

#Preview("HomeHero: нет данных") {
    HeroPreview(hero: HeroSamples.hero(.noData, value: AppFormat.emptyPressureValue, status: AppFormat.noData))
}
