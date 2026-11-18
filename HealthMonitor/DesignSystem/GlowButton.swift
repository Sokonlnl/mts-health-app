import SwiftUI

/// Поверхность кнопки с зелёным свечением: тёмно-фиолетовая заливка, зелёная градиентная кромка 1,5 pt
/// (ярче сверху-слева) и радиальный зелёный свет снизу. Приём как у плиток: на чёрном виден, в отличие от `.shadow(.inner)`.
struct GlowButtonSurface: View {
    var isPressed = false

    private let gate = AmbientMotionGate()

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.glowButton, style: .continuous)
    }

    var body: some View {
        ZStack {
            shape.fill(AppColor.glowButtonFill)
            // Зелёный свет снизу медленно плывёт вправо и влево (без «Уменьшить движение» стоит по центру).
            TimelineView(.animation(minimumInterval: nil, paused: !gate.isEnabled)) { context in
                let phase = 2 * Double.pi * context.date.timeIntervalSinceReferenceDate / Motion.buttonLightPeriod
                let shift = gate.isEnabled ? Motion.buttonLightDrift * sin(phase) : 0
                shape.fill(
                    RadialGradient(
                        colors: [AppColor.glowButtonEdge.opacity(Size.glowButtonLightOpacity), AppColor.glowButtonDeep, Color.clear],
                        center: UnitPoint(x: 0.5 + shift, y: 1),
                        startRadius: 0,
                        endRadius: Size.glowButtonLightRadius
                    )
                )
            }
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

/// Кнопка с иконкой и текстом, внутреннее зелёное свечение (ГигаЧат на главном, «Добавить измерение» на экране давления).
/// Высота 64 (растёт с крупным шрифтом), цель нажатия не меньше 44.
/// Иконка кнопки: символ SF Symbols или картинка из каталога ресурсов.
enum GlowButtonIcon {
    case system(String)
    case asset(String)
}

struct GlowButton: View {
    let title: String
    let icon: GlowButtonIcon
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlowButtonLabel(title: title, icon: icon)
        }
        .buttonStyle(GlowButtonStyle())
    }
}

private struct GlowButtonLabel: View {
    let title: String
    let icon: GlowButtonIcon

    var body: some View {
        HStack(spacing: Spacing.s) {
            iconImage
                .resizable()
                .scaledToFit()
                .frame(width: Size.glowButtonIcon, height: Size.glowButtonIcon)
                .accessibilityHidden(true)
            Text(title)
                .textStyle(.glowButtonTitle)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(TextScale.compact)
        }
        .foregroundStyle(AppColor.textPrimary)
        .frame(maxWidth: .infinity, minHeight: Size.glowButtonHeight)
        .contentShape(RoundedRectangle(cornerRadius: Radius.glowButton, style: .continuous))
    }

    private var iconImage: Image {
        switch icon {
        case .system(let name): return Image(systemName: name)
        case .asset(let name): return Image(name)
        }
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

#Preview("GlowButton: норма, нажата, добавить") {
    VStack(spacing: Spacing.l) {
        GlowButton(title: "Задать вопрос ГигаЧату", icon: .asset(HomeText.gigachatMarkAsset), action: {})
        GlowButtonLabel(title: "Задать вопрос ГигаЧату (нажата)", icon: .asset(HomeText.gigachatMarkAsset))
            .background { GlowButtonSurface(isPressed: true) }
        GlowButton(title: "Недоступная кнопка", icon: .system("plus"), action: {})
            .disabled(true)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
