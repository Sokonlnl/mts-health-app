import SwiftUI

/// Анимации из docs/DESIGN.md.
enum Motion {
    /// Длительности в секундах.
    static let standardDuration: Double = 0.25
    static let fastDuration: Double = 0.2

    /// Разворот и сворачивание блоков.
    static let standard = Animation.easeInOut(duration: standardDuration)
    /// Переключение сегментов и чипов.
    static let fast = Animation.easeInOut(duration: fastDuration)
}

#Preview("Motion") {
    MotionDemo()
}

private struct MotionDemo: View {
    @State private var isOn = false

    var body: some View {
        VStack(spacing: Spacing.l) {
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .fill(AppColor.accent)
                .frame(width: isOn ? Size.sparklineWidth * 2 : Size.sparklineWidth, height: Size.dayCircle)
            Button("standard \(Motion.standardDuration)") { withAnimation(Motion.standard) { isOn.toggle() } }
            Button("fast \(Motion.fastDuration)") { withAnimation(Motion.fast) { isOn.toggle() } }
        }
        .padding(Spacing.screenMargin)
    }
}
