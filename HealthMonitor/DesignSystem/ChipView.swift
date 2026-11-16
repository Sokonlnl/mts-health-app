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
                .foregroundStyle(isSelected ? AppColor.accent : AppColor.textSecondary)
                .padding(.horizontal, Spacing.l)
                .frame(minHeight: Spacing.minTapTarget)
                .background(isSelected ? AppColor.accentSoft : AppColor.fill, in: Capsule())
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
}
