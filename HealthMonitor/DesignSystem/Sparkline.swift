import SwiftUI

/// Мини-график. Без данных рисует пунктир.
/// `marker`: линия с маркером на последней точке (пульс).
struct Sparkline: View {
    enum Style {
        case line
        case marker
    }

    let values: [Double]
    let color: Color
    var style: Style = .line
    var height: CGFloat = Size.sparklineHeight

    var body: some View {
        GeometryReader { proxy in
            if values.count < 2 {
                dashedLine(from: 0, to: proxy.size.width, y: proxy.size.height / 2, color: AppColor.textTertiary)
            } else {
                chart(in: proxy.size)
            }
        }
        .frame(height: height)
        .accessibilityHidden(true)
    }

    private func chart(in size: CGSize) -> some View {
        let points = makePoints(in: size)
        let last = points.last ?? .zero
        return ZStack(alignment: .topLeading) {
            Path { path in
                path.addLines(points)
            }
            .stroke(color, style: StrokeStyle(lineWidth: Size.sparklineLine, lineCap: .round, lineJoin: .round))
            if style != .line {
                AuraMarker(glow: color.opacity(Size.markerGlowOpacity), glowDiameter: Size.sparklineDot * 2, dotDiameter: Size.sparklineDot)
                    .position(last)
            }
        }
    }

    private func dashedLine(from start: CGFloat, to end: CGFloat, y: CGFloat, color: Color) -> some View {
        Path { path in
            path.move(to: CGPoint(x: start, y: y))
            path.addLine(to: CGPoint(x: end, y: y))
        }
        .stroke(
            color,
            style: StrokeStyle(lineWidth: Size.sparklineLine, lineCap: .round, dash: [Spacing.xs, Spacing.s])
        )
    }

    private func makePoints(in size: CGSize) -> [CGPoint] {
        let low = values.min() ?? 0
        let high = values.max() ?? 1
        let span = max(high - low, 0.0001)
        let inset = Size.sparklineDot
        let step = (size.width - inset) / CGFloat(values.count - 1)
        return values.enumerated().map { index, value in
            let ratio = CGFloat((value - low) / span)
            return CGPoint(x: CGFloat(index) * step, y: inset + (size.height - 2 * inset) * (1 - ratio))
        }
    }
}

#Preview("Sparkline: данные") {
    VStack(spacing: Spacing.l) {
        Sparkline(values: [3, 5, 4, 7, 6, 9, 8], color: AppColor.pressure)
        Sparkline(values: [66, 68, 65, 70, 67, 69], color: AppColor.pulse, style: .marker)
    }
    .padding(Spacing.l)
    .background(AppColor.background)
}

#Preview("Sparkline: пусто") {
    Sparkline(values: [], color: AppColor.glucose)
        .padding(Spacing.l)
        .background(AppColor.background)
}
