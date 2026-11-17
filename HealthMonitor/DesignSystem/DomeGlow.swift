import SwiftUI

/// Свечение-«купол» вверху главного экрана: размытое световое пятно в форме перевёрнутого купола,
/// яркое сверху и гаснущее к `Size.domeHeight`. Цвет берётся из палитры состояния. Собрано градиентами и blur, без растров.
/// Кладётся фоном внутрь прокрутки (`.background(alignment: .top)`), уезжает вместе с содержимым.
struct DomeGlow: View {
    let palette: AuraPalette
    /// `false`: смена палитры без анимации (loading).
    var isAnimated = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isAmbientMotionEnabled) private var isAmbientMotionEnabled

    private var animation: Animation? {
        isAnimated && !reduceMotion && isAmbientMotionEnabled ? Motion.palette : nil
    }

    var body: some View {
        ZStack(alignment: .top) {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [palette.c0.opacity(Size.domeOpacity), palette.c0.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: Size.domeOuterWidth / 2
                    )
                )
                .frame(width: Size.domeOuterWidth, height: Size.domeOuterHeight)
                .blur(radius: Size.domeOuterBlur)
                .offset(y: Size.glowBleed + Size.domeOuterCenter - Size.domeOuterHeight / 2)
            Ellipse()
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: palette.c0.opacity(Size.domeOpacity), location: 0),
                            .init(color: palette.c0.opacity(Size.domeOpacity), location: 0.4),
                            .init(color: palette.c0.opacity(0), location: 1)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: Size.domeCoreWidth / 2
                    )
                )
                .frame(width: Size.domeCoreWidth, height: Size.domeCoreHeight)
                .blur(radius: Size.domeCoreBlur)
                .offset(y: Size.glowBleed + Size.domeCoreCenter - Size.domeCoreHeight / 2)
        }
        .glowBlock(
            height: Size.domeHeight, fadeStart: Size.domeFadeStart, fadeEnd: Size.domeFadeEnd, palette: palette, animation: animation
        )
    }
}

private struct DomeGlowPreview: View {
    let palette: AuraPalette
    var isAnimated = true

    var body: some View {
        ScrollView {
            Color.clear.frame(height: Size.homeColumnTop + Size.bentoHeight)
                .background(alignment: .top) { DomeGlow(palette: palette, isAnimated: isAnimated) }
        }
        .background(AppColor.homeBackground)
    }
}

#Preview("DomeGlow: норма") { DomeGlowPreview(palette: .normal) }
#Preview("DomeGlow: повышенное") { DomeGlowPreview(palette: .elevated) }
#Preview("DomeGlow: высокое") { DomeGlowPreview(palette: .high) }
#Preview("DomeGlow: нет данных") { DomeGlowPreview(palette: .noData) }
#Preview("DomeGlow: loading (без анимации)") { DomeGlowPreview(palette: .noData, isAnimated: false) }
