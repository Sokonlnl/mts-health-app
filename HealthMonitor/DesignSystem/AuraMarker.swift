import SwiftUI

/// Маркер: свечение цвета статуса и белая точка. Используется на графике давления и в мини-графике.
struct AuraMarker: View {
    let glow: Color
    var glowDiameter: CGFloat = Size.markerGlow
    var dotDiameter: CGFloat = Size.markerDot

    var body: some View {
        ZStack {
            Circle()
                .fill(glow)
                .frame(width: glowDiameter, height: glowDiameter)
                .blur(radius: glowDiameter / 4)
            Circle()
                .fill(AppColor.textPrimary)
                .frame(width: dotDiameter, height: dotDiameter)
        }
        .accessibilityHidden(true)
    }
}

#Preview("AuraMarker") {
    AuraMarker(glow: AuraPalette.normal.markerGlow)
        .padding(Spacing.xxl)
        .background(AppColor.background)
}
