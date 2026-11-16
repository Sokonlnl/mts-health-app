import SwiftUI

/// Статусная пилюля: Норма, Повышенное, Высокое, нейтральная.
struct StatusPill: View {
    let text: String
    let tone: StatusTone
    var systemImage: String?

    var body: some View {
        HStack(spacing: Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(AppTextStyle.captionStrong.font)
                    .accessibilityHidden(true)
            }
            Text(text)
                .textStyle(.captionStrong)
        }
        .foregroundStyle(tone.colors.text)
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.xs)
        .background(tone.colors.background, in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

#Preview("StatusPill: все состояния") {
    VStack(alignment: .leading, spacing: Spacing.m) {
        StatusPill(text: "Норма", tone: .positive)
        StatusPill(text: "Повышенное", tone: .caution)
        StatusPill(text: "Высокое", tone: .critical)
        StatusPill(text: "Нет данных", tone: .neutral)
        StatusPill(text: "Синхронизировано в 09:41", tone: .positive, systemImage: "checkmark.circle.fill")
    }
    .padding(Spacing.screenMargin)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColor.background)
}
