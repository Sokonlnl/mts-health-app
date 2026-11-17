import SwiftUI

/// Чип выбора (контекст измерения).
struct ChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(.bodyStrong)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.compact)
                .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                .padding(.horizontal, Spacing.l)
                .frame(minHeight: Spacing.minTapTarget)
                .background(isSelected ? AppColor.segmentActive : AppColor.fill, in: Capsule())
                .overlay { Capsule().strokeBorder(isSelected ? AppColor.glassHighlight : AppColor.glassStroke, lineWidth: Size.hairline) }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("chip-\(title)")
    }
}

#Preview("ChipView") {
    HStack {
        ChipView(title: "Утро", isSelected: true, action: {})
        ChipView(title: "Вечер", isSelected: false, action: {})
        ChipView(title: "После нагрузки", isSelected: false, action: {})
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
