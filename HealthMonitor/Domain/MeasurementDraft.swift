import Foundation

/// Поле ввода в шторке.
enum MeasurementField: CaseIterable {
    case systolic
    case diastolic
    case pulse

    /// Следующее поле; у последнего остаётся оно же.
    var next: MeasurementField {
        switch self {
        case .systolic: return .diastolic
        case .diastolic: return .pulse
        case .pulse: return .pulse
        }
    }
}

/// Проблема валидации ввода.
enum MeasurementIssue: Equatable {
    case systolicOutOfRange
    case diastolicOutOfRange
    case systolicNotAboveDiastolic
    case pulseOutOfRange

    var message: String {
        switch self {
        case .systolicOutOfRange: return "Верхнее давление: от 70 до 250"
        case .diastolicOutOfRange: return "Нижнее давление: от 40 до 150"
        case .systolicNotAboveDiastolic: return "Верхнее должно быть больше нижнего"
        case .pulseOutOfRange: return "Пульс: от 30 до 220"
        }
    }
}

/// Черновик измерения в шторке: ввод цифр и валидация.
struct MeasurementDraft: Equatable {
    static let systolicLimits = 70...250
    static let diastolicLimits = 40...150
    static let pulseLimits = 30...220
    static let maxDigits = 3

    var systolicText = ""
    var diastolicText = ""
    var pulseText = ""
    var context: MeasurementContext?
    var date: Date

    init(date: Date) {
        self.date = date
    }

    var systolic: Int? { Int(systolicText) }
    var diastolic: Int? { Int(diastolicText) }
    var pulse: Int? { Int(pulseText) }

    var issues: [MeasurementIssue] {
        var result: [MeasurementIssue] = []
        if let value = systolic, !Self.systolicLimits.contains(value) {
            result.append(.systolicOutOfRange)
        }
        if let value = diastolic, !Self.diastolicLimits.contains(value) {
            result.append(.diastolicOutOfRange)
        }
        if let top = systolic, let bottom = diastolic, top <= bottom {
            result.append(.systolicNotAboveDiastolic)
        }
        if !pulseText.isEmpty {
            let valid = pulse.map { Self.pulseLimits.contains($0) } ?? false
            if !valid {
                result.append(.pulseOutOfRange)
            }
        }
        return result
    }

    /// Можно ли сохранить: оба давления введены, все правила выполнены.
    var isValid: Bool {
        systolic != nil && diastolic != nil && issues.isEmpty
    }

    /// Подсказка об ошибке, если она есть.
    var hint: String? { issues.first?.message }

    /// Зона для строки результата. Только для корректного ввода.
    var zone: PressureZone? {
        guard isValid, let top = systolic, let bottom = diastolic else { return nil }
        return PressureZone.classify(systolic: top, diastolic: bottom)
    }

    func text(for field: MeasurementField) -> String {
        switch field {
        case .systolic: return systolicText
        case .diastolic: return diastolicText
        case .pulse: return pulseText
        }
    }

    private mutating func setText(_ text: String, for field: MeasurementField) {
        switch field {
        case .systolic: systolicText = text
        case .diastolic: diastolicText = text
        case .pulse: pulseText = text
        }
    }

    /// Добавляет цифру (до трёх знаков). Возвращает true, если поле заполнилось
    /// и фокус нужно перевести дальше.
    @discardableResult
    mutating func append(digit: Int, to field: MeasurementField) -> Bool {
        guard (0...9).contains(digit) else { return false }
        let current = text(for: field)
        guard current.count < Self.maxDigits else { return false }
        if current.isEmpty && digit == 0 { return false }
        let updated = current + String(digit)
        setText(updated, for: field)
        return updated.count == Self.maxDigits
    }

    mutating func deleteLast(from field: MeasurementField) {
        var current = text(for: field)
        guard !current.isEmpty else { return }
        current.removeLast()
        setText(current, for: field)
    }

    /// Собирает измерение, если ввод корректен.
    func makeMeasurement(id: String) -> PressureMeasurement? {
        guard isValid, let top = systolic, let bottom = diastolic else { return nil }
        return PressureMeasurement(id: id, date: date, systolic: top, diastolic: bottom, pulse: pulse, context: context)
    }
}
