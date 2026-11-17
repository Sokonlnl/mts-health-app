import SwiftUI

/// Круглая стеклянная кнопка с иконкой (назад, закрыть, «+», профиль, − и +).
struct IconButton: View {
    let systemName: String
    let label: String
    var diameter: CGFloat = Size.iconButton
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(AppTextStyle.headline.font)
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: diameter, height: diameter)
                .glassBackground(in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview("IconButton") {
    HStack(spacing: Spacing.l) {
        IconButton(systemName: "chevron.left", label: "Назад", action: {})
        IconButton(systemName: "plus", label: "Добавить", action: {})
        IconButton(systemName: "minus", label: "Уменьшить", diameter: Size.stepperButton, action: {})
        IconButton(systemName: "plus", label: "Добавить", diameter: Size.navAdd, action: {})
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
