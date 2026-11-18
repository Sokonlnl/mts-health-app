import SwiftUI

/// Содержимое шторки «Новое измерение» (контейнер и стекло: `glassSheet` в DesignSystem).
struct NewMeasurementSheet: View {
    @Bindable var viewModel: PressureViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                dateRow
                fields
                stepperRow
                if let hint = viewModel.draft.hint {
                    Text(hint)
                        .textStyle(.caption)
                        .foregroundStyle(AppColor.danger.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("sheet-hint")
                }
                contextChips
                NumericKeypad(onDigit: viewModel.inputDigit, onDelete: viewModel.deleteDigit)
                PrimaryButton(title: "Сохранить", isEnabled: viewModel.draft.isValid, action: viewModel.save)
                    .accessibilityIdentifier("save-button")
            }
            .padding(.horizontal, Spacing.screenMargin)
            .padding(.bottom, Spacing.screenMargin)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var header: some View {
        HStack {
            Text("Новое измерение")
                .textStyle(.title)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("sheet-title")
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: Spacing.s)
            IconButton(systemName: "xmark", label: "Закрыть") {
                viewModel.isSheetPresented = false
            }
            .accessibilityIdentifier("sheet-close")
        }
    }

    private var dateRow: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: "calendar")
                .textStyle(.bodyStrong.asSymbol)
                .foregroundStyle(AppColor.textSecondary)
                .accessibilityHidden(true)
            Text(viewModel.draftDateText)
                .fixedSize(horizontal: false, vertical: true)
                .textStyle(.body)
                .foregroundStyle(AppColor.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var fields: some View {
        HStack(spacing: Spacing.m) {
            fieldTile(.systolic, title: "Верхнее", unit: AppUnit.pressure, identifier: "field-systolic")
            fieldTile(.diastolic, title: "Нижнее", unit: AppUnit.pressure, identifier: "field-diastolic")
            fieldTile(.pulse, title: "Пульс", unit: AppUnit.pulse, identifier: "field-pulse")
        }
    }

    private func fieldTile(_ field: MeasurementField, title: String, unit: String, identifier: String) -> some View {
        ValueFieldTile(
            title: title,
            text: viewModel.draft.text(for: field),
            unit: unit,
            isFocused: viewModel.focusedField == field,
            action: { viewModel.focus(field) }
        )
        .accessibilityIdentifier(identifier)
    }

    /// Кнопки − и +, между ними строка «Будет: <статус>» цветом статуса.
    private var stepperRow: some View {
        HStack(spacing: Spacing.m) {
            IconButton(systemName: "minus", label: "Уменьшить значение", diameter: Size.stepperButton) {
                viewModel.stepFocused(by: -1)
            }
            .accessibilityIdentifier("stepper-minus")
            Spacer(minLength: Spacing.s)
            result
            Spacer(minLength: Spacing.s)
            IconButton(systemName: "plus", label: "Увеличить значение", diameter: Size.stepperButton) {
                viewModel.stepFocused(by: 1)
            }
            .accessibilityIdentifier("stepper-plus")
        }
    }

    @ViewBuilder
    private var result: some View {
        if let tone = viewModel.draftResultTone {
            Text(viewModel.draftResultText)
                .textStyle(.bodyStrong)
                .foregroundStyle(tone.colors.text)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("sheet-result")
        } else {
            Text(viewModel.draftResultText)
                .textStyle(.caption)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var contextChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.s) {
                ForEach(MeasurementContext.allCases) { context in
                    ChipView(title: context.title, isSelected: viewModel.draft.context == context) {
                        viewModel.toggleContext(context)
                    }
                }
            }
        }
    }
}

@MainActor
private func sheetPreview(_ configure: (PressureViewModel) -> Void) -> some View {
    let store = HealthStore(repository: MockHealthRepository(delayNanoseconds: 0))
    let viewModel = PressureViewModel(store: store)
    configure(viewModel)
    return NewMeasurementSheet(viewModel: viewModel)
        .background(AppColor.background)
}

#Preview("Шторка: пустая") {
    sheetPreview { _ in }
}

#Preview("Шторка: заполнена") {
    sheetPreview { viewModel in
        viewModel.draft.systolicText = "132"
        viewModel.draft.diastolicText = "86"
        viewModel.draft.pulseText = "70"
        viewModel.draft.context = .morning
    }
}

#Preview("Шторка: ошибка ввода") {
    sheetPreview { viewModel in
        viewModel.draft.systolicText = "80"
        viewModel.draft.diastolicText = "90"
    }
}
