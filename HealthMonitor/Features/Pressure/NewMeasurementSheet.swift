import SwiftUI

/// Шторка «Новое измерение».
struct NewMeasurementSheet: View {
    @Bindable var viewModel: PressureViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                dateRow
                fields
                contextChips
                resultRow
                NumericKeypad(onDigit: viewModel.inputDigit, onDelete: viewModel.deleteDigit)
                PrimaryButton(title: "Сохранить", isEnabled: viewModel.draft.isValid, action: viewModel.save)
                    .accessibilityIdentifier("save-button")
            }
            .padding(Spacing.screenMargin)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(AppColor.surface)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.sheet)
    }

    private var header: some View {
        HStack {
            Text("Новое измерение")
                .textStyle(.title)
                .foregroundStyle(AppColor.textPrimary)
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
                .font(AppTextStyle.bodyStrong.font)
                .foregroundStyle(AppColor.textSecondary)
                .accessibilityHidden(true)
            Text(viewModel.draftDateText)
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

    private var contextChips: some View {
        HStack(spacing: Spacing.s) {
            ForEach(MeasurementContext.allCases) { context in
                ChipView(title: context.title, isSelected: viewModel.draft.context == context) {
                    viewModel.toggleContext(context)
                }
            }
        }
    }

    private var resultRow: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text("Результат")
                    .textStyle(.label)
                    .foregroundStyle(AppColor.textSecondary)
                Spacer(minLength: Spacing.s)
                if let zone = viewModel.draft.zone {
                    StatusPill(text: zone.title, tone: zone.tone)
                        .accessibilityIdentifier("sheet-result")
                } else {
                    Text("Введите значения")
                        .textStyle(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            if let hint = viewModel.draft.hint {
                Text(hint)
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.danger.text)
                    .accessibilityIdentifier("sheet-hint")
            }
        }
        .frame(minHeight: Spacing.minTapTarget, alignment: .top)
    }
}

#Preview("Шторка: пустая") {
    let store = HealthStore(repository: MockHealthRepository(delayNanoseconds: 0))
    return NewMeasurementSheet(viewModel: PressureViewModel(store: store))
}

#Preview("Шторка: заполнена") {
    let store = HealthStore(repository: MockHealthRepository(delayNanoseconds: 0))
    let viewModel = PressureViewModel(store: store)
    viewModel.draft.systolicText = "132"
    viewModel.draft.diastolicText = "86"
    viewModel.draft.pulseText = "70"
    viewModel.draft.context = .morning
    return NewMeasurementSheet(viewModel: viewModel)
}

#Preview("Шторка: ошибка ввода") {
    let store = HealthStore(repository: MockHealthRepository(delayNanoseconds: 0))
    let viewModel = PressureViewModel(store: store)
    viewModel.draft.systolicText = "80"
    viewModel.draft.diastolicText = "90"
    return NewMeasurementSheet(viewModel: viewModel)
}
