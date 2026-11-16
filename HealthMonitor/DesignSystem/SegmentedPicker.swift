import SwiftUI

/// Переключатель периодов (День, Неделя, Месяц, 6 мес).
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
        .background(AppColor.segmentTrack, in: RoundedRectangle(cornerRadius: Radius.controlLarge, style: .continuous))
    }

    private func segment(_ option: Option) -> some View {
        let isSelected = option == selection
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = option
            }
        } label: {
            Text(title(option))
                .textStyle(.bodyStrong)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                .frame(maxWidth: .infinity, minHeight: Spacing.minTapTarget)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                            .fill(AppColor.surface)
                    }
                }
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
