import SwiftUI

/// Крупное значение с единицей измерения.
///
/// `isPlaceholder` включает цвет textTertiary: допустимо только для чисто декоративного прочерка
/// (рядом всегда есть читаемый текст, например «Нет данных»). См. раздел «Контраст» в docs/DESIGN.md.
struct MetricValueText: View {
    let value: String
    let unit: String
    var style: AppTextStyle = .metricCard
    var isPlaceholder = false
    var spacing: CGFloat = Spacing.xs
    var valueIdentifier = ""

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: spacing) {
            Text(value)
                .textStyle(style)
                .foregroundStyle(isPlaceholder ? AppColor.textTertiary : AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.metric)
                .accessibilityLabel(isPlaceholder ? Text(AppFormat.noData) : Text(value))
                .accessibilityIdentifier(valueIdentifier)
            if !unit.isEmpty {
                Text(unit)
                    .textStyle(.label)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(TextScale.compact)
            }
        }
    }
}

#Preview("MetricValueText") {
    VStack(alignment: .leading, spacing: Spacing.l) {
        MetricValueText(value: "122/79", unit: AppUnit.pressure)
        MetricValueText(value: "72,4", unit: AppUnit.weight, style: .metricCardSmall)
        MetricValueText(value: AppFormat.dash, unit: AppUnit.glucose, isPlaceholder: true)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
