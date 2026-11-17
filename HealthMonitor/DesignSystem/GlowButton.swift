import SwiftUI

/// Поверхность кнопки с зелёным свечением: тёмно-фиолетовая заливка, зелёная градиентная кромка 1,5 pt
/// (ярче сверху-слева) и радиальный зелёный свет снизу. Приём как у плиток: на чёрном виден, в отличие от `.shadow(.inner)`.
struct GlowButtonSurface: View {
    var isPressed = false

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.glowButton, style: .continuous)
    }

    var body: some View {
        ZStack {
            shape.fill(AppColor.glowButtonFill)
            shape.fill(
                RadialGradient(
                    colors: [AppColor.glowButtonEdge.opacity(Size.glowButtonLightOpacity), AppColor.glowButtonDeep, Color.clear],
                    center: .bottom,
                    startRadius: 0,
                    endRadius: Size.glowButtonLightRadius
                )
            )
            shape.strokeBorder(
                LinearGradient(
                    colors: [
                        AppColor.glowButtonEdge,
                        AppColor.glowButtonEdge.opacity(Size.glowButtonRimMidOpacity),
                        AppColor.glowButtonEdge.opacity(Size.glowButtonRimEndOpacity)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: Size.glowButtonRim
            )
        }
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
