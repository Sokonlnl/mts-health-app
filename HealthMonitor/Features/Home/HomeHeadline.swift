import SwiftUI

/// Заголовок-вывод (34,6 pt) в верхнем блоке, пояснение 14 pt и «Подробнее / Свернуть». Ширина текста 272.
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
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text(headline.summary)
                    .textStyle(.insightSummary)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: Size.insightWidth)
            .contentSwap(headline.contentKey)
            if let details = headline.details {
                if isExpanded {
                    Text(details)
                        .textStyle(.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: Size.insightWidth)
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
                    .textStyle(.captionStrong.asSymbol)
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
            headline: HeadlineModel(title: "У вас отличные показатели", summary: "Все ваши показатели в норме", details: "Подробности"),
            isExpanded: false,
            onToggle: {}
        )
        HomeHeadline(
            headline: HeadlineModel(
                title: "У вас отличные показатели",
                summary: "Все ваши показатели в норме",
                details: "Подробности недели."
            ),
            isExpanded: true,
            onToggle: {}
        )
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("HomeHeadline: без подробностей") {
    HomeHeadline(
        headline: HeadlineModel(title: "Пока нет данных", summary: "Измерений давления пока нет.", details: nil),
        isExpanded: false,
        onToggle: {}
    )
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
