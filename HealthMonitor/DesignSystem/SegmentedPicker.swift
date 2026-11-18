import SwiftUI

/// Переключатель. `.capsule`: периоды (День, Неделя, Месяц, 6 мес) в стеклянной капсуле, активный сегмент белый 16%.
/// `.tabs`: вкладки верхнего блока («Самочувствие», «Анализы»): без капсулы, выбранная светлая с точкой 5×5 под названием,
/// остальные приглушены; цель нажатия не меньше 44×44.
struct SegmentedPicker<Option: Hashable>: View {
    enum Style {
        case capsule
        case tabs
    }

    let options: [Option]
    @Binding var selection: Option
    let title: (Option) -> String
    var style: Style = .capsule
    var identifierPrefix = "segment"
    /// Полный идентификатор сегмента. `nil`: `<identifierPrefix>-<название>`.
    var identifier: ((Option) -> String)?

    var body: some View {
        switch style {
        case .capsule:
            // Крупный шрифт: если сегменты не помещаются в ширину, переключатель прокручивается по горизонтали.
            ViewThatFits(in: .horizontal) {
                row
                ScrollView(.horizontal, showsIndicators: false) { row.fixedSize() }
            }
            .padding(Spacing.xs)
            .glassBackground(in: Capsule())
        case .tabs:
            HStack(spacing: Size.tabGap) {
                ForEach(options, id: \.self) { option in
                    tab(option)
                }
            }
        }
    }

    private var row: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                segment(option)
            }
        }
    }

    private func segmentIdentifier(_ option: Option) -> String {
        identifier?(option) ?? "\(identifierPrefix)-\(title(option))"
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
                .lineLimit(2)
                .multilineTextAlignment(.center)
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
        .accessibilityIdentifier(segmentIdentifier(option))
    }

    private func tab(_ option: Option) -> some View {
        let isSelected = option == selection
        return Button {
            withAnimation(Motion.segment) {
                selection = option
            }
        } label: {
            VStack(spacing: Spacing.xs) {
                Text(title(option))
                    .textStyle(.cardLabel)
                    .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textDim)
                    .lineLimit(1)
                    .minimumScaleFactor(TextScale.compact)
                Circle()
                    .fill(isSelected ? AppColor.textPrimary : Color.clear)
                    .frame(width: Size.tabDot, height: Size.tabDot)
            }
            .frame(minWidth: Spacing.minTapTarget, minHeight: Spacing.minTapTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier(segmentIdentifier(option))
    }
}

private struct SegmentedPickerDemo: View {
    @State private var selection = "Неделя"
    @State private var tab = "Самочувствие"

    var body: some View {
        VStack(spacing: Spacing.xl) {
            SegmentedPicker(options: ["День", "Неделя", "Месяц", "6 мес"], selection: $selection, title: { $0 })
            SegmentedPicker(options: ["Самочувствие", "Анализы"], selection: $tab, title: { $0 }, style: .tabs)
        }
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
    }
}

#Preview("SegmentedPicker: капсула и вкладки") {
    SegmentedPickerDemo()
}
