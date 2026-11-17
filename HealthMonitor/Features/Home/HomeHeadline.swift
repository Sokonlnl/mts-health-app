import SwiftUI

/// Заголовок-вывод в зоне свечения, пояснение и «Подробнее / Свернуть».
struct HomeHeadline: View {
    let headline: HeadlineModel
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: Spacing.s) {
            VStack(spacing: Spacing.headlineGap) {
                Text(headline.title)
                    .textStyle(.insightTitle)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text(headline.summary)
                    .textStyle(.insightSummary)
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
                    .textStyle(.captionStrong)
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

#Preview("HomeHeadline: свёрнуто и развёрнуто") {
    VStack(spacing: Spacing.xl) {
        HomeHeadline(
            headline: HeadlineModel(title: "Всё спокойно", summary: "Давление в норме 7 из 7 дней.", details: "Подробности"),
            isExpanded: false,
            onToggle: {}
        )
        HomeHeadline(
            headline: HeadlineModel(title: "Всё спокойно", summary: "Давление в норме 7 из 7 дней.", details: "Подробности недели."),
            isExpanded: true,
            onToggle: {}
        )
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.homeBackground)
}

#Preview("HomeHeadline: без подробностей") {
    HomeHeadline(
        headline: HeadlineModel(title: "Пока нет данных", summary: "Измерений давления пока нет.", details: nil),
        isExpanded: false,
        onToggle: {}
    )
    .padding(Spacing.screenMargin)
    .background(AppColor.homeBackground)
}
