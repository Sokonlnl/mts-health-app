import SwiftUI

/// Фон верхнего блока главного экрана: экспорт свечения из Figma 63:25250 (`Assets.xcassets/HeroGlow`, 390×540, прозрачный фон,
/// скругление 42 со всех сторон, свечение опущено к низу). Для повышенного, высокого и «нет данных» картинка обесцвечивается и
/// тонируется цветом палитры зоны (`AuraPalette.glow`). Поверх мягко «дышит»: масштаб и яркость в пределах 2–3%, период
/// `Motion.heroBreathePeriod`. При «Уменьшить движение» и `isAmbientMotionEnabled == false` без дыхания.
/// `level`: общая яркость 0...1 (заставка: свечение разгорается из темноты).
/// Заполняет отданное место: высоту задаёт вызывающий (`Size.heroHeight`, `Size.heroCompactHeight`); картинка прижата вниз.
struct HeroGlowImage: View {
    let palette: AuraPalette
    /// `false`: смена палитры без анимации (loading).
    var isAnimated = true
    var level = 1.0

    private let gate = AmbientMotionGate()

    private var animation: Animation? {
        isAnimated && gate.isEnabled ? Motion.palette : nil
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.hero, style: .continuous)
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: !gate.isEnabled)) { context in
            image(time: gate.isEnabled ? context.date.timeIntervalSinceReferenceDate : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .clipShape(shape)
        .opacity(level)
        .animation(animation, value: palette)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func image(time: TimeInterval) -> some View {
        let wave = sin(2 * Double.pi * time / Motion.heroBreathePeriod)
        return Image("HeroGlow")
            .resizable()
            .scaledToFill()
            .saturation(palette.tintsHeroGlow ? 0 : 1)
            .colorMultiply(palette.tintsHeroGlow ? palette.glow : Color.white)
            .scaleEffect(1 + Motion.heroBreatheScaleAmplitude * wave, anchor: .bottom)
            .opacity(1 + Motion.heroBreatheOpacityAmplitude * wave)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

private struct HeroGlowImagePreview: View {
    let palette: AuraPalette
    var height = Size.heroHeight
    var level = 1.0

    var body: some View {
        HeroGlowImage(palette: palette, level: level)
            .frame(height: height)
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
            .background(AppColor.background)
    }
}

#Preview("HeroGlowImage: норма (дышит)") { HeroGlowImagePreview(palette: .normal) }
#Preview("HeroGlowImage: повышенное") { HeroGlowImagePreview(palette: .elevated) }
#Preview("HeroGlowImage: высокое") { HeroGlowImagePreview(palette: .high) }
#Preview("HeroGlowImage: нет данных") { HeroGlowImagePreview(palette: .noData) }
#Preview("HeroGlowImage: компактный") { HeroGlowImagePreview(palette: .noData, height: Size.heroCompactHeight) }
#Preview("HeroGlowImage: заставка, середина") { HeroGlowImagePreview(palette: .normal, level: 0.4) }
#Preview("HeroGlowImage: без движения") {
    HeroGlowImagePreview(palette: .normal).environment(\.isAmbientMotionEnabled, false)
}
