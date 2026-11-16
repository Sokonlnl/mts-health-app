import SwiftUI

/// Кольцо-показатель: число в центре, подпись снизу.
struct RingGauge: View {
    let progress: Double
    let color: Color
    let centerText: String
    let caption: String
    var isEmpty = false
    var accessibilityText = ""

    private var clamped: CGFloat {
        CGFloat(min(max(progress, 0), 1))
    }

    var body: some View {
        VStack(spacing: Spacing.s) {
            ZStack {
                Circle()
                    .stroke(AppColor.fill, lineWidth: Size.ringLine)
                if !isEmpty {
                    Circle()
                        .trim(from: 0, to: clamped)
                        .stroke(color, style: StrokeStyle(lineWidth: Size.ringLine, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                Text(centerText)
                    .textStyle(.headline)
                    // Прочерк декоративный: смысл дублируют подпись и accessibilityValue (DESIGN.md, «Контраст»).
                    .foregroundStyle(isEmpty ? AppColor.textTertiary : AppColor.textPrimary)
            }
            .frame(width: Size.ring, height: Size.ring)
            Text(caption)
                .textStyle(.label)
                .foregroundStyle(AppColor.textSecondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(caption)
        .accessibilityValue(accessibilityText)
    }
}

#Preview("RingGauge: нормальное") {
    HStack {
        RingGauge(progress: 6.0 / 7.0, color: AppColor.pressure, centerText: "6/7", caption: "Давление")
        RingGauge(progress: 1, color: AppColor.pulse, centerText: "7/7", caption: "Пульс")
        RingGauge(progress: 5.0 / 7.0, color: AppColor.weight, centerText: "5/7", caption: "Вес")
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.surface)
}

#Preview("RingGauge: пустое") {
    RingGauge(progress: 0, color: AppColor.pressure, centerText: AppFormat.dash, caption: "Давление", isEmpty: true)
        .padding(Spacing.screenMargin)
        .background(AppColor.surface)
}
