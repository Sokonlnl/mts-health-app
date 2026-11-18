import SwiftUI

/// Шторка «Подробнее» под заголовком-выводом главного экрана: вывод, пояснение и расширенный текст по неделе.
struct InsightSheet: View {
    let headline: HeadlineModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.m) {
                Text(headline.title)
                    .textStyle(.insightTitle)
                    .foregroundStyle(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text(headline.summary)
                    .textStyle(.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let details = headline.details {
                    Text(details)
                        .textStyle(.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("insight-details")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.screenMargin)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.l)
        }
        .background(AppColor.background.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .accessibilityIdentifier("insight-sheet")
    }
}

#Preview("InsightSheet") {
    InsightSheet(
        headline: HeadlineModel(
            title: "У вас отличные показатели",
            summary: "Все ваши показатели в норме",
            details: "Давление в норме 6 из 7 измеренных дней. Продолжайте измерять в одно и то же время."
        )
    )
}
