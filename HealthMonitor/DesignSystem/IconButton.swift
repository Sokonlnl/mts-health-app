import SwiftUI

/// Круглая стеклянная кнопка с иконкой (назад, закрыть, «+», профиль, − и +).
/// `surface`: обычное стекло или `.profile` (плитка Figma: белый 3%, кромка белый 55%).
struct IconButton: View {
    let systemName: String
    let label: String
    var diameter: CGFloat = Size.iconButton
    var surface: GlassStyle = .material
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(AppTextStyle.headline.font)
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: diameter, height: diameter)
                .glassBackground(in: Circle(), style: surface)
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
        IconButton(systemName: "person", label: "Профиль", surface: .profile, action: {})
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.homeBackground)
}
