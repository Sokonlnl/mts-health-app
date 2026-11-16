import SwiftUI

/// Плитка поля ввода значения (верхнее, нижнее, пульс) для шторки с цифровой клавиатурой.
struct ValueFieldTile: View {
    let title: String
    let text: String
    let unit: String
    let isFocused: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.textSecondary)
                Text(text.isEmpty ? AppFormat.dash : text)
                    .textStyle(.metricCard)
                    // Прочерк декоративный: название и единица остаются textSecondary (DESIGN.md, «Контраст»).
                    .foregroundStyle(text.isEmpty ? AppColor.textTertiary : AppColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(TextScale.metric)
                Text(unit)
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: Size.fieldTile)
            .padding(.vertical, Spacing.s)
            .background(AppColor.fill, in: RoundedRectangle(cornerRadius: Radius.controlLarge, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.controlLarge, style: .continuous)
                    .stroke(isFocused ? AppColor.accent : Color.clear, lineWidth: Size.focusRing)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(text.isEmpty ? "не заполнено" : "\(text) \(unit)")
        .accessibilityAddTraits(isFocused ? .isSelected : [])
    }
}

#Preview("ValueFieldTile") {
    HStack {
        ValueFieldTile(title: "Верхнее", text: "122", unit: AppUnit.pressure, isFocused: true, action: {})
        ValueFieldTile(title: "Нижнее", text: "", unit: AppUnit.pressure, isFocused: false, action: {})
        ValueFieldTile(title: "Пульс", text: "68", unit: AppUnit.pulse, isFocused: false, action: {})
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.surface)
}
