import SwiftUI

/// Декоративное размытое пятно-эллипс цвета в правом нижнем углу карточки (карточка совета). Заполняет родителя, прижато
/// к правому нижнему углу и сдвинуто за край на `shift`; родитель обрезает его формой карточки (`clipShape`).
/// Скрыто от VoiceOver. Сердце карточки давления рисует `HeartGlow`.
struct CornerGlow: View {
    let color: Color
    let size: CGSize
    let blur: CGFloat
    let opacity: Double
    let shift: CGFloat

    var body: some View {
        Ellipse()
            .frame(width: size.width, height: size.height)
            .foregroundStyle(color.opacity(opacity))
            .blur(radius: blur)
            .offset(x: shift, y: shift)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

#Preview("CornerGlow: эллипс") {
    Color.clear
        .frame(width: Size.smallCardHeight, height: Size.smallCardHeight)
        .background {
            CornerGlow(
                color: AppColor.success.text, size: CGSize(width: Size.adviceGlowSize, height: Size.adviceGlowSize),
                blur: Size.adviceGlowBlur, opacity: Size.adviceGlowOpacity, shift: Size.cornerGlowShift
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.tile, style: .continuous))
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
