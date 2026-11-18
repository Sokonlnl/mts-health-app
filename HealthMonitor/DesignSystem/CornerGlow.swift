import SwiftUI

/// Декоративное размытое пятно цвета в правом нижнем углу карточки (облако, сердце). Заполняет родителя, прижато к
/// правому нижнему углу и сдвинуто за край на `shift`; родитель обрезает его формой карточки (`clipShape`).
/// Форма пятна (`Ellipse`, `Image`) приходит снаружи. Скрыто от VoiceOver.
struct CornerGlow<Glyph: View>: View {
    let color: Color
    let size: CGSize
    let blur: CGFloat
    let opacity: Double
    let shift: CGFloat
    @ViewBuilder let glyph: () -> Glyph

    var body: some View {
        glyph()
            .frame(width: size.width, height: size.height)
            .foregroundStyle(color.opacity(opacity))
            .blur(radius: blur)
            .offset(x: shift, y: shift)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

extension CornerGlow where Glyph == Ellipse {
    /// Пятно-эллипс (карточка совета).
    init(color: Color, size: CGSize, blur: CGFloat, opacity: Double, shift: CGFloat) {
        self.init(color: color, size: size, blur: blur, opacity: opacity, shift: shift) { Ellipse() }
    }
}

#Preview("CornerGlow: эллипс и сердце") {
    HStack(spacing: Spacing.l) {
        Color.clear
            .frame(width: Size.smallCardHeight, height: Size.smallCardHeight)
            .background {
                CornerGlow(
                    color: AppColor.success.text, size: CGSize(width: Size.adviceGlowSize, height: Size.adviceGlowSize),
                    blur: Size.adviceGlowBlur, opacity: Size.adviceGlowOpacity, shift: Size.cornerGlowShift
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.tile, style: .continuous))
        Color.clear
            .frame(width: Size.smallCardHeight, height: Size.smallCardHeight)
            .background {
                CornerGlow(
                    color: AppColor.warning.text, size: CGSize(width: Size.heartSize, height: Size.heartSize),
                    blur: Size.heartBlur, opacity: Size.heartOpacity, shift: Size.cornerGlowShift
                ) {
                    Image(systemName: "heart.fill").resizable().scaledToFit()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.tile, style: .continuous))
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
