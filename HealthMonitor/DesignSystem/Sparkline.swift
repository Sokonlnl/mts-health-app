import SwiftUI

/// Мини-график. Без данных рисует пунктир.
struct Sparkline: View {
    let values: [Double]
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            if values.count < 2 {
                dashedLine(in: proxy.size)
            } else {
                linePath(in: proxy.size)
                    .stroke(color, style: StrokeStyle(lineWidth: Size.sparklineLine, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: Size.sparklineWidth, height: Size.sparklineHeight)
        .accessibilityHidden(true)
    }

    private func dashedLine(in size: CGSize) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: size.height / 2))
            path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
        }
        .stroke(
            AppColor.textTertiary,
            style: StrokeStyle(lineWidth: Size.sparklineLine, lineCap: .round, dash: [Spacing.xs, Spacing.s])
        )
    }

    private func linePath(in size: CGSize) -> Path {
        let low = values.min() ?? 0
        let high = values.max() ?? 1
        let span = max(high - low, 0.0001)
        let step = size.width / CGFloat(values.count - 1)
        var path = Path()
        for (index, value) in values.enumerated() {
            let ratio = CGFloat((value - low) / span)
            let point = CGPoint(x: CGFloat(index) * step, y: size.height - ratio * size.height)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }
}

#Preview("Sparkline: данные") {
    Sparkline(values: [3, 5, 4, 7, 6, 9, 8], color: AppColor.pressure)
        .padding(Spacing.l)
}

#Preview("Sparkline: пусто") {
    Sparkline(values: [], color: AppColor.glucose)
        .padding(Spacing.l)
}
