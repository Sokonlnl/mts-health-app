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

    /// Верх блока упирается в край экрана (без скругления), скруглён только низ.
    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 0, bottomLeadingRadius: Radius.hero,
            bottomTrailingRadius: Radius.hero, topTrailingRadius: 0, style: .continuous
        )
    }

    var body: some View {
        // Размер задаёт `Color.clear` (высота верхнего блока), картинка (заполняет по ширине, выше блока) рисуется поверх, прижата вниз
        // и обрезается формой: иначе она раздувала фон и купол выступал за нижнюю границу блока.
        Color.clear
            .overlay {
                GeometryReader { geo in
                    TimelineView(.animation(minimumInterval: nil, paused: !gate.isEnabled)) { context in
                        // Картинка выше блока на радиус скругления (её верхние углы, скруглены в экспорте, уходят за край),
                        // шире на «дыхание» и дрейф с каждой стороны и ниже на дрейф: при сжатии и сдвиге фон не обнажается.
                        let time = gate.isEnabled ? context.date.timeIntervalSinceReferenceDate : 0
                        let bleed = geo.size.width * Motion.heroBreatheScaleAmplitude + Motion.heroDriftX
                        let driftX = Motion.heroDriftX * CGFloat(sin(2 * Double.pi * time / Motion.heroDriftPeriodX))
                        let driftY = Motion.heroDriftY * CGFloat(cos(2 * Double.pi * time / Motion.heroDriftPeriodY))
                        image(
                            time: time,
                            size: CGSize(
                                width: geo.size.width + bleed * 2,
                                height: geo.size.height + Radius.hero + Motion.heroDriftY * 2
                            )
                        )
                        .offset(x: -bleed + driftX, y: -(Radius.hero + Motion.heroDriftY) + driftY)
                    }
                }
            }
            .clipShape(shape)
        .opacity(level)
        .animation(animation, value: palette)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func image(time: TimeInterval, size: CGSize) -> some View {
        let wave = sin(2 * Double.pi * time / Motion.heroBreathePeriod)
        return Image("HeroGlow")
            .resizable()
            .frame(width: size.width, height: size.height)
            .saturation(palette.tintsHeroGlow ? 0 : 1)
            .colorMultiply(palette.tintsHeroGlow ? palette.glow : Color.white)
            .scaleEffect(1 + Motion.heroBreatheScaleAmplitude * wave, anchor: .bottom)
            .opacity(1 + Motion.heroBreatheOpacityAmplitude * wave)
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
