import SwiftUI

/// Поверхность кнопки с зелёным свечением: тёмно-фиолетовая заливка и два внутренних свечения
/// (кромка `-1 -1` blur 4.4 и глубокое `0 -4` blur 50.7).
struct GlowButtonSurface: View {
    var isPressed = false

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.glowButton, style: .continuous)
            .fill(
                AppColor.glowButtonFill
                    .shadow(.inner(color: AppColor.glowButtonEdge, radius: Size.glowEdgeRadius, x: -Size.rimOffset, y: -Size.rimOffset))
                    .shadow(.inner(color: AppColor.glowButtonEdge, radius: Size.glowEdgeRadius, x: Size.rimOffset, y: Size.rimOffset))
                    .shadow(.inner(color: AppColor.glowButtonDeep, radius: Size.glowDeepRadius, x: 0, y: -Size.glowDeepOffset))
            )
            .opacity(isPressed ? Size.pressedOpacity : 1)
            .accessibilityHidden(true)
    }
}

/// Кнопка с иконкой и текстом, внутреннее зелёное свечение. Высота 64, цель нажатия не меньше 44.
struct GlowButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlowButtonLabel(title: title, systemImage: systemImage)
        }
        .buttonStyle(GlowButtonStyle())
    }
}

private struct GlowButtonLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: Size.glowButtonIcon, height: Size.glowButtonIcon)
                .accessibilityHidden(true)
            Text(title)
                .textStyle(.glowButtonTitle)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.compact)
        }
        .foregroundStyle(AppColor.textPrimary)
        .frame(maxWidth: .infinity, minHeight: Size.glowButtonHeight)
        .contentShape(RoundedRectangle(cornerRadius: Radius.glowButton, style: .continuous))
    }
}

private struct GlowButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background { GlowButtonSurface(isPressed: configuration.isPressed) }
            .opacity(isEnabled ? 1 : Size.disabledOpacity)
    }
}

#Preview("GlowButton: норма, нажата, disabled") {
    VStack(spacing: Spacing.l) {
        GlowButton(title: "Давление", systemImage: "play.fill", action: {})
        GlowButtonLabel(title: "Давление (нажата)", systemImage: "play.fill")
            .background { GlowButtonSurface(isPressed: true) }
        GlowButton(title: "Давление (disabled)", systemImage: "play.fill", action: {})
            .disabled(true)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.homeBackground)
}
