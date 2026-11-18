import SwiftUI

/// Малая карточка: подпись, значение и пояснение цветом статуса («Среднее», «Диапазон верхнего»).
/// Одна связка для VoiceOver; идентификатор задаёт вызывающий на самой карточке (внутри связки он не виден XCUI).
struct StatCard: View {
    let title: String
    let value: String
    let detail: String
    var detailTone: StatusTone = .neutral

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .textStyle(.label)
                .foregroundStyle(AppColor.textSecondary)
            Text(value)
                .textStyle(.heroHeadline)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.metric)
            Text(detail)
                .textStyle(.captionStrong)
                .foregroundStyle(detailTone.colors.text)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .glassCard(insets: CardInsets.compact)
        .accessibilityElement(children: .combine)
    }
}

#Preview("StatCard") {
    HStack(spacing: Spacing.m) {
        StatCard(title: "Среднее", value: "125/80", detail: "Норма", detailTone: .positive)
        StatCard(title: "Диапазон верхнего", value: "118–142", detail: "В норме 5 из 7")
    }
    .fixedSize(horizontal: false, vertical: true)
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
