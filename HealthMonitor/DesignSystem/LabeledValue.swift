import SwiftUI

/// Подпись и значение (диапазон, среднее).
struct LabeledValue: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .textStyle(.caption)
                .foregroundStyle(AppColor.textSecondary)
            Text(value)
                .textStyle(.bodyStrong)
                .foregroundStyle(AppColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview("LabeledValue") {
    HStack {
        LabeledValue(title: "Диапазон", value: "118–136 / 74–88")
        LabeledValue(title: "Среднее", value: "125/80")
    }
    .padding(Spacing.screenMargin)
}
