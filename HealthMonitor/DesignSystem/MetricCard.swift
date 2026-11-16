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
                        .foregroundStyle(AppColor.textSecondary)
                }
                MetricValueText(
                    value: valueText ?? AppFormat.dash,
                    unit: unit,
                    isPlaceholder: valueText == nil
                )
                Text(statusText)
                    .textStyle(.captionStrong)
                    .foregroundStyle(statusColor)
            }
            Spacer(minLength: 0)
            Sparkline(values: series, color: kind.color)
        }
        .cardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind.title)
        .accessibilityValue(valueText.map { "\($0) \(unit), \(statusText)" } ?? statusText)
    }
}

#Preview("MetricCard: значения") {
    VStack(spacing: Spacing.l) {
        MetricCard(
            kind: .pulse, valueText: "68", unit: AppUnit.pulse,
            statusText: "В покое", tone: .neutral, series: [66, 68, 65, 70, 67]
        )
        MetricCard(
            kind: .weight, valueText: "72,4", unit: AppUnit.weight,
            statusText: "−0,8 кг за 2 недели", tone: .neutral, series: [73.2, 73, 72.8, 72.6, 72.4]
        )
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("MetricCard: тона статуса") {
    VStack(spacing: Spacing.l) {
        MetricCard(
            kind: .pressure, valueText: "122/79", unit: AppUnit.pressure,
            statusText: "Норма", tone: .positive, series: [120, 124, 118, 131, 124, 119, 128]
        )
        MetricCard(
            kind: .pressure, valueText: "134/86", unit: AppUnit.pressure,
            statusText: "Повышенное", tone: .caution, series: [126, 130, 128, 134, 132, 136, 134]
        )
        MetricCard(
            kind: .pressure, valueText: "148/94", unit: AppUnit.pressure,
            statusText: "Высокое", tone: .critical, series: [132, 138, 141, 146, 144, 150, 148]
        )
        MetricCard(
            kind: .pulse, valueText: "68", unit: AppUnit.pulse,
            statusText: "В покое", tone: .neutral, series: [66, 68, 65, 70, 67]
        )
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("MetricCard: пусто") {
    MetricCard(
        kind: .glucose, valueText: nil, unit: AppUnit.glucose,
        statusText: AppFormat.noData, tone: .neutral, series: []
    )
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

/// У карточки показателя loading и error показываются на уровне списка: скелетон и сообщение об ошибке.
#Preview("MetricCard: loading") {
    SkeletonList()
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}

#Preview("MetricCard: error") {
    ErrorStateView(message: "Сервис временно недоступен. Проверьте соединение и повторите попытку.", retry: {})
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
