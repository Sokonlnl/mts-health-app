import SwiftUI

/// Карточка показателя на главном экране: иконка, стрелка, значение, статус, мини-график.
/// Пустое состояние: `valueText == nil` (прочерк и пунктир).
struct MetricCard: View {
    let kind: MetricKind
    let valueText: String?
    let unit: String
    let statusText: String
    let tone: StatusTone
    let series: [Double]

    private var statusColor: Color {
        tone == .neutral ? AppColor.textSecondary : tone.colors.text
    }

    var body: some View {
        HStack(spacing: Spacing.l) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                HStack(spacing: Spacing.s) {
                    Image(systemName: kind.iconName)
                        .font(AppTextStyle.captionStrong.font)
                        .foregroundStyle(kind.color)
                        .frame(width: Size.metricIcon, height: Size.metricIcon)
                        .background(AppColor.fill, in: Circle())
                    Text(kind.title)
                        .textStyle(.label)
                        .foregroundStyle(AppColor.textSecondary)
                    Image(systemName: "chevron.right")
                        .font(AppTextStyle.caption.font)
                        .foregroundStyle(AppColor.textTertiary)
                }
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    Text(valueText ?? AppFormat.dash)
                        .textStyle(.metricCard)
                        .foregroundStyle(valueText == nil ? AppColor.textTertiary : AppColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(unit)
                        .textStyle(.label)
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                }
                Text(statusText)
                    .textStyle(.captionStrong)
                    .foregroundStyle(statusColor)
            }
            Spacer(minLength: 0)
            Sparkline(values: series, color: kind.color)
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind.title)
        .accessibilityValue(valueText.map { "\($0) \(unit), \(statusText)" } ?? statusText)
    }
}

#Preview("MetricCard: значения") {
    VStack(spacing: Spacing.l) {
        MetricCard(
            kind: .pressure, valueText: "122/79", unit: "мм рт. ст.",
            statusText: "Норма", tone: .positive, series: [120, 124, 118, 131, 124, 119, 128]
        )
        MetricCard(
            kind: .pulse, valueText: "68", unit: "уд/мин",
            statusText: "В покое", tone: .neutral, series: [66, 68, 65, 70, 67]
        )
        MetricCard(
            kind: .weight, valueText: "72,4", unit: "кг",
            statusText: "−0,8 кг за 2 недели", tone: .neutral, series: [73.2, 73, 72.8, 72.6, 72.4]
        )
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("MetricCard: пусто") {
    MetricCard(kind: .glucose, valueText: nil, unit: "ммоль/л", statusText: "Нет данных", tone: .neutral, series: [])
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
