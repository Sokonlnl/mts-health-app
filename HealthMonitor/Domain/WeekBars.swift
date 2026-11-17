import Foundation

/// Столбик давления за один из последних семи дней.
struct WeekBar: Identifiable, Equatable {
    let id: Int
    let label: String
    let systolic: Int?
    let isElevated: Bool
    let isToday: Bool
    /// Высота столбика 0...1. Ноль, если в этот день нет измерений.
    let ratio: Double

    var accessibilityText: String {
        guard let systolic else { return "\(label): нет измерений" }
        return "\(label): верхнее \(systolic)"
    }
}

enum WeekBars {
    static let days = 7
    /// Верхнее давление, которому соответствует минимальная и полная высота столбика.
    static let lowerBound = 100.0
    static let upperBound = 150.0
    static let minimumRatio = 0.25

    /// Последние 7 суток, последний столбик: сегодня. Для дня берётся наибольшее верхнее давление.
    static func make(measurements: [PressureMeasurement], now: Date, calendar: Calendar = AppCalendar.calendar) -> [WeekBar] {
        let today = calendar.startOfDay(for: now)
        return (0..<days).map { index in
            let day = calendar.date(byAdding: .day, value: index - (days - 1), to: today) ?? today
            let items = measurements.filter { calendar.isDate($0.date, inSameDayAs: day) }
            let top = items.map(\.systolic).max()
            let weekday = calendar.component(.weekday, from: day)
            return WeekBar(
                id: index,
                label: WeekOverview.labels[(weekday + 5) % 7],
                systolic: top,
                isElevated: items.contains { $0.zone > .normal },
                isToday: index == days - 1,
                ratio: top.map { barRatio(for: $0) } ?? 0
            )
        }
    }

    private static func barRatio(for systolic: Int) -> Double {
        let value = (Double(systolic) - lowerBound) / (upperBound - lowerBound)
        return min(max(value, minimumRatio), 1)
    }
}
