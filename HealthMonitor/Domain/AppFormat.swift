import Foundation

/// Форматирование значений и дат для UI (русская локаль).
enum AppFormat {
    /// Русская локаль для дат и осей графиков (не зависит от языка симулятора).
    static let locale = Locale(identifier: "ru_RU")
    static let dash = "–"
    /// Подпись пустого состояния показателя.
    static let noData = "Нет данных"
    /// Подпись пустого состояния последнего измерения.
    static let noMeasurements = "Нет измерений"
    /// Пустое значение давления: «–/–».
    static let emptyPressureValue = "\(dash)/\(dash)"

    /// Подписи карточек показателей на главном экране.
    static let restingStatus = "В покое"
    static let lastValue = "Последнее значение"
    static let noMeasurementsYet = "Измерений пока нет"
    static let addMeasurement = "Добавить измерение"
    static let notFilled = "не заполнено"
    static let inputUnavailable = "Ввод этого показателя пока недоступен"

    static func time(_ date: Date) -> String {
        format(date, pattern: "HH:mm")
    }

    static func historyDate(_ date: Date, now: Date) -> String {
        let calendar = AppCalendar.calendar
        if calendar.isDate(date, inSameDayAs: now) {
            return "Сегодня, \(time(date))"
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now), calendar.isDate(date, inSameDayAs: yesterday) {
            return "Вчера, \(time(date))"
        }
        return format(date, pattern: "d MMM, HH:mm")
    }

    static func pressureValue(_ systolic: Int, _ diastolic: Int) -> String {
        "\(systolic)/\(diastolic)"
    }

    /// Значение давления с пульсом для строки истории: «132/86 · 70».
    static func measurementTitle(_ measurement: PressureMeasurement) -> String {
        let value = pressureValue(measurement.systolic, measurement.diastolic)
        guard let pulse = measurement.pulse else { return value }
        return "\(value) · \(pulse)"
    }

    /// Дата и контекст для строки истории: «Сегодня, 08:10 · Утро».
    static func measurementSubtitle(_ measurement: PressureMeasurement, now: Date) -> String {
        let date = historyDate(measurement.date, now: now)
        guard let context = measurement.context else { return date }
        return "\(date) · \(context.title)"
    }

    /// Пульс с единицей: «70 уд/мин», без значения прочерк.
    static func pulseValue(_ pulse: Int?) -> String {
        guard let pulse else { return dash }
        return "\(pulse) \(AppUnit.pulse)"
    }

    static func range(_ range: ClosedRange<Int>?) -> String {
        guard let range else { return dash }
        if range.lowerBound == range.upperBound { return "\(range.lowerBound)" }
        return "\(range.lowerBound)–\(range.upperBound)"
    }

    /// Число с одним знаком и запятой: 72,4.
    static func decimal(_ value: Double) -> String {
        String(format: "%.1f", value).replacingOccurrences(of: ".", with: ",")
    }

    private static func format(_ date: Date, pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = AppCalendar.calendar
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }
}
