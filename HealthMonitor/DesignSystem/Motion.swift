import SwiftUI

/// Анимации из docs/DESIGN.md. Длительности и кривые только отсюда.
/// При `accessibilityReduceMotion` вращение и «дыхание» формы отключаются (см. `AuraOrb`).
enum Motion {
    /// Длительности в секундах.
    static let standardDuration: Double = 0.25
    static let fastDuration: Double = 0.2
    static let paletteDuration: Double = 1.1
    static let contentSwapDuration: Double = 0.7

    /// Разворот и сворачивание блоков.
    static let standard = Animation.easeInOut(duration: standardDuration)
    /// Остальные быстрые переходы.
    static let fast = Animation.easeInOut(duration: fastDuration)
    /// Смена палитры при смене состояния или показателя (кроссфейд форм).
    static let palette = Animation.easeInOut(duration: paletteDuration)
    /// Появление текста значения и заголовка.
    static let contentSwap = Animation.timingCurve(0.2, 0.7, 0.2, 1, duration: contentSwapDuration)
    /// Перемещение маркера на дуге.
    static let marker = Animation.timingCurve(0.3, 0.7, 0.2, 1, duration: 0.8)
    /// Подсветка выбранной пилюли показателя.
    static let pillSelect = Animation.easeOut(duration: 0.45)
    /// Переключатель периодов.
    static let segment = Animation.easeInOut(duration: 0.3)
    /// Выезд шторки.
    static let sheet = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.45)
    /// Подложка под шторкой.
    static let sheetScrim = Animation.easeInOut(duration: 0.25)

    // Форма Aura
    static let orbSpinA = Animation.linear(duration: 28).repeatForever(autoreverses: false)
    static let orbSpinB = Animation.linear(duration: 19).repeatForever(autoreverses: false)
    static let orbSpinContour = Animation.linear(duration: 40).repeatForever(autoreverses: false)
    static let orbBreathe = Animation.easeInOut(duration: 7).repeatForever(autoreverses: true)

    /// Появление: прозрачность 0 в 1, сдвиг вниз на 8 pt, масштаб 0,98 в 1.
    static let contentSwapTransition = AnyTransition.opacity
        .combined(with: .offset(y: 8))
        .combined(with: .scale(scale: 0.98))
}

/// Фоновое движение (вращение и «дыхание» формы Aura). Выключается в snapshot-тестах,
/// чтобы кадр был детерминированным. Системный `accessibilityReduceMotion` проверяется отдельно.
private struct AmbientMotionKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var isAmbientMotionEnabled: Bool {
        get { self[AmbientMotionKey.self] }
        set { self[AmbientMotionKey.self] = newValue }
    }
}

#Preview("Motion") {
    MotionDemo()
}

private struct MotionDemo: View {
    @State private var isOn = false

    var body: some View {
        VStack(spacing: Spacing.l) {
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .fill(AppColor.textPrimary)
                .frame(width: isOn ? 176 : 88, height: Size.iconButton)
            Button("standard \(Motion.standardDuration)") { withAnimation(Motion.standard) { isOn.toggle() } }
            Button("palette \(Motion.paletteDuration)") { withAnimation(Motion.palette) { isOn.toggle() } }
            Button("segment") { withAnimation(Motion.segment) { isOn.toggle() } }
        }
        .padding(Spacing.screenMargin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}
