import SwiftUI

/// Главная кнопка. `filled`: «Сохранить» (primaryFill, высота 56). `glass`: «Добавить измерение» на экране (высота 56).
/// `outline`: контурная кнопка в пустой карточке (высота 44). Выключенная `filled` выглядит нейтрально.
struct PrimaryButton: View {
    enum Style {
        case filled
        case glass
        case outline
    }

    let title: String
    var style: Style = .filled
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(.bodyStrong)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.compact)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, minHeight: height)
                .background { backgroundShape }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private var height: CGFloat {
        style == .outline ? Size.compactButton : Size.primaryButton
    }

    private var textColor: Color {
        switch style {
        case .filled: return isEnabled ? AppColor.primaryText : AppColor.textTertiary
        case .glass, .outline: return AppColor.textPrimary
        }
    }

    @ViewBuilder
    private var backgroundShape: some View {
        switch style {
        case .filled:
            Capsule().fill(isEnabled ? AppColor.primaryFill : AppColor.fill)
        case .glass:
            GlassSurface(shape: Capsule())
        case .outline:
            Capsule().strokeBorder(AppColor.glassHighlight, lineWidth: Size.hairline)
        }
    }
}

#Preview("PrimaryButton: включена") {
    VStack(spacing: Spacing.l) {
        PrimaryButton(title: "Сохранить", action: {})
        PrimaryButton(title: "Добавить измерение", style: .glass, action: {})
        PrimaryButton(title: "Добавить измерение", style: .outline, action: {})
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("PrimaryButton: выключена") {
    PrimaryButton(title: "Сохранить", isEnabled: false, action: {})
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
