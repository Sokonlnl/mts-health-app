import SwiftUI

/// Статусная пилюля: Норма, Повышенное, Высокое, Нет данных.
/// `.standard`: фон белый 8%, контур белый 14%. `.tinted` (карточка давления): фон цвета тона 6%, без контура,
/// 14 semibold, не меньше 76×35.
struct StatusPill: View {
    enum Style {
        case standard
        case tinted
    }

    let text: String
    let tone: StatusTone
    var systemImage: String?
    var style: Style = .standard

    private var isTinted: Bool { style == .tinted }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .textStyle(.captionStrong.asSymbol)
                    .accessibilityHidden(true)
            }
            Text(text)
                .textStyle(isTinted ? .chipLabel : .captionStrong)
                .lineLimit(1)
        }
        .foregroundStyle(tone.colors.text)
        .padding(.horizontal, isTinted ? Spacing.l : Spacing.m)
        .padding(.vertical, Spacing.xs)
        .frame(minWidth: isTinted ? Size.chipMinWidth : nil, minHeight: isTinted ? Size.chipHeight : nil)
        .background(isTinted ? tone.colors.text.opacity(AppColor.chipTintOpacity) : tone.colors.background, in: Capsule())
        .overlay {
            if !isTinted {
                Capsule().strokeBorder(tone.colors.stroke, lineWidth: Size.hairline)
            }
        }
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
        StatusPill(text: "Норма", tone: .positive, style: .tinted)
        StatusPill(text: "Повышенное", tone: .caution, style: .tinted)
        StatusPill(text: "Высокое", tone: .critical, style: .tinted)
        StatusPill(text: "Нет данных", tone: .neutral, style: .tinted)
        StatusDotLabel(text: "Норма", tone: .positive)
        StatusDotLabel(text: "Высокое", tone: .critical)
    }
    .padding(Spacing.screenMargin)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColor.background)
}
