import SwiftUI

/// Верхний блок со свечением (главный экран 63:25250 и экран давления): тёмный центр, зелёная подсветка у нижнего края и
/// по бокам, скругление снизу `Radius.hero`. Цвет берётся из палитры зоны (норма зелёный, повышенное янтарный,
/// высокое красный, нет данных серый). Собрано градиентами и blur, без растров.
/// Свечение мягко «дышит»: масштаб и яркость пятен меняются на несколько процентов, цикл `Motion.breathePeriod`,
/// у пятен разные фазы. При «Уменьшить движение» и при выключенном `isAmbientMotionEnabled` дыхания и анимации палитры нет.
/// `level`: общая яркость 0...1 (заставка: свечение разгорается из темноты).
/// Заполняет отданное место: высоту задаёт вызывающий (`Size.heroHeight`, `Size.heroCompactHeight`, `Size.pressureHeroHeight`).
/// Кладётся фоном верхнего блока внутри прокрутки (уезжает вместе с содержимым).
struct DomeGlow: View {
    let palette: AuraPalette
    /// `false`: смена палитры без анимации (loading).
    var isAnimated = true
    var level = 1.0

    private let gate = AmbientMotionGate()

    private var animation: Animation? {
        isAnimated && gate.isEnabled ? Motion.palette : nil
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: Radius.hero,
            bottomTrailingRadius: Radius.hero,
            topTrailingRadius: 0,
            style: .continuous
        )
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: !gate.isEnabled)) { context in
            layers(time: gate.isEnabled ? context.date.timeIntervalSinceReferenceDate : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .clipShape(shape)
        .opacity(level)
        .animation(animation, value: palette)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func layers(time: TimeInterval) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [palette.glow.opacity(Size.domeWashTop), palette.glow.opacity(Size.domeWashBottom)],
                startPoint: .top,
                endPoint: .bottom
            )
            blob(width: Size.domeBlobWidth, height: Size.domeBlobHeight, blur: Size.domeBlobBlur, opacity: Size.domeOpacity)
                .modifier(Breathing(time: time, phase: Motion.breathePhases[0]))
                .offset(y: Size.domeBlobDrop)
            blob(width: Size.domeSideWidth, height: Size.domeSideHeight, blur: Size.domeSideBlur, opacity: Size.domeSideOpacity)
                .modifier(Breathing(time: time, phase: Motion.breathePhases[1]))
                .offset(x: -Size.domeSideShift)
            blob(width: Size.domeSideWidth, height: Size.domeSideHeight, blur: Size.domeSideBlur, opacity: Size.domeSideOpacity)
                .modifier(Breathing(time: time, phase: Motion.breathePhases[2]))
                .offset(x: Size.domeSideShift)
        }
    }

    private func blob(width: CGFloat, height: CGFloat, blur: CGFloat, opacity: Double) -> some View {
        Ellipse()
            .fill(palette.glow.opacity(opacity))
            .frame(width: width, height: height)
            .blur(radius: blur)
    }
}

/// «Дыхание» пятна: масштаб и яркость колеблются по синусоиде вокруг 1 (`Motion.breathe*`), фаза у каждого пятна своя.
private struct Breathing: ViewModifier {
    let time: TimeInterval
    let phase: Double

    func body(content: Content) -> some View {
        let wave = sin(2 * Double.pi * time / Motion.breathePeriod + phase)
        return content
            .scaleEffect(1 + Motion.breatheScaleAmplitude * wave)
            .opacity(1 + Motion.breatheOpacityAmplitude * wave)
    }
}

private struct DomeGlowPreview: View {
    let palette: AuraPalette
    var isAnimated = true
    var height = Size.heroHeight
    var level = 1.0

    var body: some View {
        ScrollView {
            DomeGlow(palette: palette, isAnimated: isAnimated, level: level)
                .frame(height: height)
        }
        .ignoresSafeArea()
        .background(AppColor.background)
    }
}

#Preview("DomeGlow: норма (дышит)") { DomeGlowPreview(palette: .normal) }
#Preview("DomeGlow: повышенное") { DomeGlowPreview(palette: .elevated) }
#Preview("DomeGlow: высокое") { DomeGlowPreview(palette: .high) }
#Preview("DomeGlow: нет данных") { DomeGlowPreview(palette: .noData) }
#Preview("DomeGlow: loading (без анимации)") { DomeGlowPreview(palette: .noData, isAnimated: false) }
#Preview("DomeGlow: компактный (empty, error)") { DomeGlowPreview(palette: .noData, height: Size.heroCompactHeight) }
#Preview("DomeGlow: экран давления") { DomeGlowPreview(palette: .normal, height: Size.pressureHeroHeight) }
#Preview("DomeGlow: заставка, середина") { DomeGlowPreview(palette: .normal, level: 0.4) }
#Preview("DomeGlow: «Уменьшить движение» (без дыхания)") {
    DomeGlowPreview(palette: .normal).environment(\.isAmbientMotionEnabled, false)
}
