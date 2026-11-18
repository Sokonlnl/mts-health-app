import Foundation

/// Шторка добавления измерения: черновик, результат и действия.
extension PressureViewModel {
    /// Дата в шторке: текущий момент относительно «сейчас», а не относительно самой даты черновика.
    var draftDateText: String {
        AppFormat.historyDate(draft.date, now: now())
    }

    /// Строка результата в шторке: «Будет: Норма» или подсказка ввести значения.
    var draftResultText: String {
        guard let zone = draft.zone else { return "Введите значения" }
        return "Будет: \(zone.title)"
    }

    /// Тон строки результата: `nil`, пока зона не определена (значения не введены).
    var draftResultTone: StatusTone? { draft.zone?.tone }

    /// Открывает шторку после появления экрана, если это запрошено (UI-тесты).
    func presentSheetIfRequested() async {
        guard opensSheetOnAppear else { return }
        opensSheetOnAppear = false
        try? await Task.sleep(nanoseconds: Self.sheetOpenDelayNanoseconds)
        openSheet()
    }

    func openSheet() {
        draft = MeasurementDraft(date: now())
        focusedField = .systolic
        isSheetPresented = true
    }

    func focus(_ field: MeasurementField) {
        focusedField = field
    }

    func inputDigit(_ digit: Int) {
        if draft.append(digit: digit, to: focusedField) {
            focusedField = focusedField.next
        }
    }

    func deleteDigit() {
        draft.deleteLast(from: focusedField)
    }

    /// Кнопки − и +: меняют значение в выбранном поле на `delta` в пределах правил валидации.
    /// Пустое поле получает типичное значение.
    func stepFocused(by delta: Int) {
        let limits: ClosedRange<Int>
        let fallback: Int
        switch focusedField {
        case .systolic:
            limits = MeasurementDraft.systolicLimits
            fallback = 120
        case .diastolic:
            limits = MeasurementDraft.diastolicLimits
            fallback = 80
        case .pulse:
            limits = MeasurementDraft.pulseLimits
            fallback = 70
        }
        let current = draft.text(for: focusedField)
        let next = Int(current).map { min(max($0 + delta, limits.lowerBound), limits.upperBound) } ?? fallback
        switch focusedField {
        case .systolic: draft.systolicText = String(next)
        case .diastolic: draft.diastolicText = String(next)
        case .pulse: draft.pulseText = String(next)
        }
    }

    func toggleContext(_ context: MeasurementContext) {
        draft.context = draft.context == context ? nil : context
    }

    func save() {
        guard let measurement = draft.makeMeasurement(id: UUID().uuidString) else { return }
        store.add(measurement)
        isSheetPresented = false
    }
}
