import SwiftUI

/// Живая форма Aura: два размытых пятна, радужный контур, тонкая окружность и содержимое по центру.
/// Смена палитры: кроссфейд старой и новой формы за `Motion.palette`.
/// Вращение и «дыхание» отключаются при `accessibilityReduceMotion` и при `isAnimated == false` (loading).
/// Слои скрыты от VoiceOver: значение и статус читаются одной связкой из содержимого (см. `AuraOrbCenter`).
struct AuraOrb<Center: View>: View {
    let palette: AuraPalette
    /// Диаметр тонкой окружности; сама форма меньше на `Size.orbRingInset`.
    let diameter: CGFloat
    let isAnimated: Bool
    private let center: Center

    init(
        palette: AuraPalette,
        diameter: CGFloat,
        isAnimated: Bool = true,
        @ViewBuilder center: () -> Center
    ) {
        self.palette = palette
        self.diameter = diameter
        self.isAnimated = isAnimated
        self.center = center()
    }

    var body: some View {
        ZStack {
            OrbLayers(palette: palette, diameter: diameter - Size.orbRingInset, isAnimated: isAnimated)
                .id(OrbIdentity(palette: palette, isAnimated: isAnimated))
                .transition(.opacity)
                .accessibilityHidden(true)
            Circle()
                .stroke(AppColor.orbRing, lineWidth: Size.hairline)
                .frame(width: diameter, height: diameter)
                .accessibilityHidden(true)
            center
        }
        .frame(width: diameter, height: diameter)
        .animation(Motion.palette, value: palette)
    }
}

/// Идентичность слоёв формы: при смене палитры старые слои уходят, новые появляются (кроссфейд).
private struct OrbIdentity: Hashable {
    let palette: AuraPalette
    let isAnimated: Bool
}

private struct OrbLayers: View {
    let palette: AuraPalette
    let diameter: CGFloat
    let isAnimated: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isAmbientMotionEnabled) private var isAmbientMotionEnabled
    @State private var spinA = 0.0
    @State private var spinB = 0.0
    @State private var spinContour = 0.0
    @State private var isBreathing = false

    var body: some View {
        ZStack {
            blobA
            blobB
            contour
        }
        .frame(width: diameter, height: diameter)
        .scaleEffect(isBreathing ? 1.045 : 1)
        .onAppear(perform: startMotion)
    }

    /// Пятно A: угловой градиент c0...c4, размытие 26, opacity 0,62, лёгкая деформация.
    private var blobA: some View {
        Circle()
            .fill(AngularGradient(colors: palette.colors + [palette.c0], center: .center))
            .blur(radius: 26)
            .opacity(0.62)
            .scaleEffect(isBreathing ? 1.06 : 1)
            .rotationEffect(.degrees(spinA))
    }

    /// Пятно B: порядок c3, c0, c4, c1, c2, размытие 18, screen, opacity 0,45, против часовой.
    private var blobB: some View {
        Circle()
            .fill(AngularGradient(colors: [palette.c3, palette.c0, palette.c4, palette.c1, palette.c2, palette.c3], center: .center))
            .padding(diameter * 0.08)
            .blur(radius: 18)
            .blendMode(.screen)
            .opacity(0.45)
            .rotationEffect(.degrees(spinB))
    }

    /// Радужный контур: c4, c1, c3, c0, c2, толщина 2,5 pt.
    private var contour: some View {
        Circle()
            .strokeBorder(
                AngularGradient(colors: [palette.c4, palette.c1, palette.c3, palette.c0, palette.c2, palette.c4], center: .center),
                lineWidth: 2.5
            )
            .opacity(0.9)
            .rotationEffect(.degrees(spinContour))
    }

    private func startMotion() {
        // Флаги читаются один раз при появлении: snapshot-тесты задают их до рендера.
        guard isAnimated, !reduceMotion, isAmbientMotionEnabled else { return }
        withAnimation(Motion.orbSpinA) { spinA = 360 }
        withAnimation(Motion.orbSpinB) { spinB = -360 }
        withAnimation(Motion.orbSpinContour) { spinContour = 360 }
        withAnimation(Motion.orbBreathe) { isBreathing = true }
    }
}

private struct OrbPreview: View {
    let palette: AuraPalette
    let title: String
    var isAnimated = true

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            AuraOrb(palette: palette, diameter: Size.orbPressure, isAnimated: isAnimated) {
                VStack(spacing: Spacing.xs) {
                    Text("122/79")
                        .textStyle(.heroValue)
                        .foregroundStyle(AppColor.textPrimary)
                        .shadow(color: AppColor.textShadow, radius: Size.textShadowRadius)
                    Text(title)
                        .textStyle(.label)
                        .foregroundStyle(AppColor.textPrimary)
                }
            }
        }
    }
}

#Preview("AuraOrb: норма") {
    OrbPreview(palette: .normal, title: "Норма")
}

#Preview("AuraOrb: повышенное") {
    OrbPreview(palette: .elevated, title: "Повышенное")
}

#Preview("AuraOrb: высокое") {
    OrbPreview(palette: .high, title: "Высокое")
}

#Preview("AuraOrb: нет данных") {
    OrbPreview(palette: .noData, title: "Нет данных")
}

#Preview("AuraOrb: loading (без вращения)") {
    OrbPreview(palette: .noData, title: "Загрузка", isAnimated: false)
}
