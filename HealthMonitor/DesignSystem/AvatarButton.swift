import SwiftUI

/// Круглая кнопка профиля с фото внутри стеклянного кольца (Figma 63:25250: кольцо с подсветкой по зоне давления).
/// Фото берётся из каталога ресурсов по имени, кнопка подписана для VoiceOver.
struct AvatarButton: View {
    let imageName: String
    let label: String
    var diameter: CGFloat = Size.iconButton
    /// Отсвет кромки кольца (цвет зоны давления).
    var tint: Color?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .scaleEffect(Size.avatarPhotoZoom, anchor: UnitPoint(x: 0.5, y: 0.2))
                .frame(width: diameter - Size.avatarInset * 2, height: diameter - Size.avatarInset * 2)
                .clipShape(Circle())
                .frame(width: diameter, height: diameter)
                .glassBackground(in: Circle(), style: .profile, tint: tint)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview("AvatarButton") {
    HStack(spacing: Spacing.l) {
        AvatarButton(imageName: "ProfileAvatar", label: "Профиль", tint: AppColor.success.text, action: {})
        AvatarButton(imageName: "ProfileAvatar", label: "Профиль", action: {})
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
