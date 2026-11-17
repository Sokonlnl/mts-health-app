import SwiftUI

/// Свечение вверху экрана: два размытых пятна (c1 слева, c2 справа), гаснет маской к низу.
/// Кладётся фоном внутрь прокрутки (`.background(alignment: .top)`), уезжает вместе с содержимым.
struct TopGlow: View {
    let palette: AuraPalette
    /// Высота блока: 620 на главном экране, 460 на экране давления.
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            blob(palette.c1)
                .offset(x: -Size.glowBlob * 0.4, y: Size.glowBleed - Size.glowBlob * 0.2)
            blob(palette.c2)
                .offset(x: Size.glowBlob * 0.45, y: Size.glowBleed - Size.glowBlob * 0.1)
        }
        .opacity(0.5)
        .frame(maxWidth: .infinity)
        .frame(height: height + Size.glowBleed, alignment: .top)
        .mask {
            LinearGradient(
                stops: [
                    .init(color: Color.black, location: 0),
                    .init(color: Color.black, location: 0.3),
                    .init(color: Color.clear, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .offset(y: -Size.glowBleed)
        .animation(Motion.palette, value: palette)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: AppColor.background.opacity(0), location: 0),
                .init(color: AppColor.background.opacity(0.9), location: 0.35),
                .init(color: AppColor.background, location: 0.6)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: Size.bottomFadeHeight)
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
            .background(alignment: .top) { TopGlow(palette: .normal, height: Size.glowHomeHeight) }
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
