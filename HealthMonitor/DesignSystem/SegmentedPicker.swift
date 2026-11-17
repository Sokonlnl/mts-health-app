import SwiftUI

/// Переключатель периодов (День, Неделя, Месяц, 6 мес) в стеклянной капсуле. Активный сегмент белый 16%.
struct SegmentedPicker<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    let title: (Option) -> String
    var identifierPrefix = "segment"

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                segment(option)
            }
        }
        .padding(Spacing.xs)
        .glassBackground(in: Capsule())
    }

    private func segment(_ option: Option) -> some View {
        let isSelected = option == selection
        return Button {
            withAnimation(Motion.segment) {
                selection = option
            }
        } label: {
            Text(title(option))
                .textStyle(.bodyStrong)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.compact)
                .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                .frame(maxWidth: .infinity, minHeight: Size.segmentHeight)
                .background {
                    if isSelected {
                        Capsule().fill(AppColor.segmentActive)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("\(identifierPrefix)-\(title(option))")
    }
}

private struct SegmentedPickerDemo: View {
    @State private var selection = "Неделя"

    var body: some View {
        SegmentedPicker(options: ["День", "Неделя", "Месяц", "6 мес"], selection: $selection, title: { $0 })
            .padding(Spacing.screenMargin)
            .background(AppColor.background)
    }
}

#Preview("SegmentedPicker") {
    SegmentedPickerDemo()
}
