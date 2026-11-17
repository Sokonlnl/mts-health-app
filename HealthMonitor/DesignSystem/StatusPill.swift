import SwiftUI

/// Статусная пилюля: Норма, Повышенное, Высокое, Нет данных. Фон белый 8%, контур белый 14%.
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
                .lineLimit(1)
        }
        .foregroundStyle(tone.colors.text)
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.xs)
        .background(tone.colors.background, in: Capsule())
        .overlay { Capsule().strokeBorder(tone.colors.stroke, lineWidth: Size.hairline) }
        .accessibilityElement(children: .combine)
    }
}

/// Статус точкой и цветным текстом (строки истории).
struct StatusDotLabel: View {
    let text: String
    let tone: StatusTone

    var body: some View {
        HStack(spacing: Spacing.s) {
            Circle()
                .fill(tone.colors.text)
                .frame(width: Size.statusDot, height: Size.statusDot)
                .accessibilityHidden(true)
            Text(text)
                .textStyle(.captionStrong)
                .foregroundStyle(tone.colors.text)
                .lineLimit(1)
        }
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
        StatusDotLabel(text: "Норма", tone: .positive)
        StatusDotLabel(text: "Высокое", tone: .critical)
    }
    .padding(Spacing.screenMargin)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColor.background)
}
