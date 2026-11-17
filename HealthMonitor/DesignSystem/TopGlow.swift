import SwiftUI

/// Общая оболочка свечений (`TopGlow`, `DomeGlow`): кадр с выносом вверх под статус-бар, маска затухания
/// (`fadeStart`, `fadeEnd` в долях высоты блока с выносом), анимация смены палитры.
extension View {
    func glowBlock(height: CGFloat, fadeStart: Double, fadeEnd: Double, palette: AuraPalette, animation: Animation?) -> some View {
        frame(maxWidth: .infinity)
            .frame(height: height + Size.glowBleed, alignment: .top)
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: Color.black, location: 0),
                        .init(color: Color.black, location: fadeStart),
                        .init(color: Color.clear, location: fadeEnd)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .offset(y: -Size.glowBleed)
            .animation(animation, value: palette)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

/// Свечение вверху экрана давления: два размытых пятна (c1 слева, c2 справа), гаснет маской к низу.
/// Кладётся фоном внутрь прокрутки (`.background(alignment: .top)`), уезжает вместе с содержимым.
struct TopGlow: View {
    let palette: AuraPalette
    /// Высота блока: `Size.glowPressureHeight` на экране давления.
    let height: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .top) {
            blob(palette.c1)
                .offset(x: -Size.glowBlob * 0.4, y: Size.glowBleed - Size.glowBlob * 0.2)
            blob(palette.c2)
                .offset(x: Size.glowBlob * 0.45, y: Size.glowBleed - Size.glowBlob * 0.1)
        }
        .opacity(0.5)
        .glowBlock(
            height: height, fadeStart: Size.glowFadeStart, fadeEnd: Size.glowFadeEnd,
            palette: palette, animation: reduceMotion ? nil : Motion.palette
        )
    }

    private func blob(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: Size.glowBlob, height: Size.glowBlob)
            .blur(radius: Size.glowBlur)
    }
}

/// Градиент к фону над плавающей навигацией и внизу экрана: контент гаснет, внизу чистый тёмный фон.
struct BottomFade: View {
    var color = AppColor.background
    var height = Size.bottomFadeHeight

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: color.opacity(0), location: 0),
                .init(color: color.opacity(0.9), location: 0.35),
                .init(color: color, location: 0.6)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: height)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview("BottomFade") {
    ZStack(alignment: .bottom) {
        AppColor.textSecondary
        BottomFade()
    }
    .background(AppColor.background)
}

#Preview("TopGlow: норма") {
    ScrollView {
        Color.clear.frame(height: 700)
            .background(alignment: .top) { TopGlow(palette: .normal, height: Size.glowPressureHeight) }
    }
    .background(AppColor.background)
}

#Preview("TopGlow: высокое") {
    ScrollView {
        Color.clear.frame(height: 700)
            .background(alignment: .top) { TopGlow(palette: .high, height: Size.glowPressureHeight) }
    }
    .background(AppColor.background)
}
