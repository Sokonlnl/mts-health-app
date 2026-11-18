import SwiftUI

/// Сердце в правом нижнем углу большой карточки давления (Figma `heart.svg`): основной слой с радиальным градиентом цвета зоны
/// (центр 60%, края 100%) и размытием 16,4, сверху два внутренних слоя поменьше чёрным: overlay 67% и hard light 20%
/// с размытием 15,8. Рамка 330×296 вынесена за угол карточки, родитель обрезает её формой карточки.
/// Бьётся мягким «дыханием-ударом» с периодом `HeartbeatRhythm`. Без ритма, при «Уменьшить движение» и при выключенном
/// `isAmbientMotionEnabled` сердце неподвижно. Скрыто от VoiceOver.
struct HeartGlow: View {
    /// Где стоит сердце: в углу большой карточки или под значением в верхнем блоке страницы показателя (Figma 86:123,
    /// сердце крупнее в 1,33 раза, по центру, верхняя часть ниже середины блока).
    enum Placement {
        case cardCorner
        case hero
    }

    let color: Color
    var rhythm: HeartbeatRhythm?
    var placement: Placement = .cardCorner

    private let gate = AmbientMotionGate()

    var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: !(gate.isEnabled && rhythm != nil))) { context in
            // Размер определяет `Color.clear` (место, отданное родителем), а рамка сердца 330×296 только рисуется поверх:
            // иначе она раздувает фон карточки выше и ниже самой карточки (карточка наползала на соседние блоки).
            Color.clear
                .overlay(alignment: placement == .hero ? .top : .bottomTrailing) {
                    switch placement {
                    case .cardCorner:
                        layers
                            .scaleEffect(scale(at: context.date), anchor: Size.heartGradientCenter)
                            .frame(width: Size.heartFrame.width, height: Size.heartFrame.height)
                            .offset(x: Size.heartOffsetX, y: Size.heartOffsetY)
                    case .hero:
                        layers
                            .scaleEffect(scale(at: context.date), anchor: Size.heartGradientCenter)
                            .frame(width: Size.heartFrame.width, height: Size.heartFrame.height)
                            .scaleEffect(Size.heroHeartScale, anchor: .top)
                            .offset(x: Size.heroHeartOffsetX, y: Size.heroHeartOffsetY)
                    }
                }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var layers: some View {
        ZStack {
            HeartShape(layer: .outer)
                .fill(
                    RadialGradient(
                        colors: [color.opacity(AppColor.heartCenterOpacity), color],
                        center: Size.heartGradientCenter, startRadius: 0, endRadius: Size.heartGradientRadius
                    )
                )
                .blur(radius: Size.heartBlur)
            HeartShape(layer: .inner)
                .fill(Color.black)
                .blur(radius: Size.heartInnerBlur)
                .opacity(Size.heartOverlayOpacity)
                .blendMode(.overlay)
            HeartShape(layer: .inner)
                .fill(Color.black)
                .blur(radius: Size.heartInnerBlur)
                .opacity(Size.heartHardLightOpacity)
                .blendMode(.hardLight)
        }
        .compositingGroup()
    }

    private func scale(at date: Date) -> Double {
        guard gate.isEnabled, let rhythm else { return 1 }
        return rhythm.scale(at: date.timeIntervalSinceReferenceDate, amplitude: Motion.heartbeatAmplitude)
    }
}

private struct HeartGlowPreview: View {
    let color: Color
    var rhythm: HeartbeatRhythm?

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: Size.pressureCardHeight)
            .background(AppColor.solidCardFill)
            .overlay { HeartGlow(color: color, rhythm: rhythm) }
            .clipShape(RoundedRectangle(cornerRadius: Radius.heroCard, style: .continuous))
            .padding(Spacing.screenMargin)
            .background(AppColor.background)
    }
}

#Preview("HeartGlow: норма, бьётся") { HeartGlowPreview(color: AppColor.success.text, rhythm: HeartbeatRhythm(pulse: 68)) }
#Preview("HeartGlow: повышенное") { HeartGlowPreview(color: AppColor.warning.text) }
#Preview("HeartGlow: высокое") { HeartGlowPreview(color: AppColor.danger.text) }
#Preview("HeartGlow: без движения") {
    HeartGlowPreview(color: AppColor.success.text, rhythm: HeartbeatRhythm(pulse: 68))
        .environment(\.isAmbientMotionEnabled, false)
}
