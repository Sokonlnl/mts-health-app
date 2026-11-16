import SwiftUI

/// Круглая кнопка с иконкой: белая (назад, закрыть) или акцентная («+»).
struct IconButton: View {
    enum Style {
        case surface
        case accent
    }

    let systemName: String
    let label: String
    var style: Style = .surface
    var diameter: CGFloat = Size.iconButton
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(AppTextStyle.headline.font)
                .foregroundStyle(style == .accent ? AppColor.surface : AppColor.textPrimary)
                .frame(width: diameter, height: diameter)
                .background(style == .accent ? AppColor.accent : AppColor.surface, in: Circle())
                .cardShadow()
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview("IconButton") {
    HStack(spacing: Spacing.l) {
        IconButton(systemName: "chevron.left", label: "Назад", action: {})
        IconButton(systemName: "plus", label: "Добавить", style: .accent, action: {})
        IconButton(systemName: "plus", label: "Добавить", style: .accent, diameter: Size.addButton, action: {})
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
