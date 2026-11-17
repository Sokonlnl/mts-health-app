import Foundation

/// Календарь приложения: григорианский, неделя с понедельника.
enum AppCalendar {
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        calendar.locale = AppFormat.locale
        return calendar
    }
}

/// День в строке недели.
struct WeekDay: Identifiable, Equatable {
    let id: Int
    let label: String
    let dayNumber: Int
    let hasMeasurement: Bool
    let isElevated: Bool
    let isToday: Bool

    var accessibilityText: String {
        var parts = [label, "\(dayNumber)"]
        if isToday { parts.append("сегодня") }
        if hasMeasurement { parts.append(isElevated ? "есть измерение, значение повышено" : "есть измерение") }
        return parts.joined(separator: ", ")
    }
}

/// Сколько дней из последних 7 были с измерением и сколько из них в норме.
struct WeekStats: Equatable {
    let normalDays: Int
    let measuredDays: Int
}

enum WeekOverview {
    static let labels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

    /// Текущая неделя Пн–Вс.
    static func days(measurements: [PressureMeasurement], now: Date, calendar: Calendar = AppCalendar.calendar) -> [WeekDay] {
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? calendar.startOfDay(for: now)
        return labels.indices.map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: weekStart) ?? weekStart
            let items = measurements.filter { calendar.isDate($0.date, inSameDayAs: day) }
            let elevated = items.contains { $0.zone > .normal }
            return WeekDay(
                id: offset,
                label: labels[offset],
                dayNumber: calendar.component(.day, from: day),
                hasMeasurement: !items.isEmpty,
                isElevated: elevated,
                isToday: calendar.isDate(day, inSameDayAs: now)
            )
        }
    }

    /// Статистика за последние 7 суток, включая сегодня.
    static func stats(measurements: [PressureMeasurement], now: Date, calendar: Calendar = AppCalendar.calendar) -> WeekStats {
        let today = calendar.startOfDay(for: now)
        var normal = 0
        var measured = 0
        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let items = measurements.filter { calendar.isDate($0.date, inSameDayAs: day) }
            if items.isEmpty { continue }
            measured += 1
            let allNormal = items.allSatisfy { $0.zone == .normal }
            if allNormal { normal += 1 }
        }
        return WeekStats(normalDays: normal, measuredDays: measured)
    }
}

/// Короткий и расширенный вывод по неделе. Без диагнозов.
struct WeekInsight: Equatable {
    let title: String
    let summary: String
    let details: String

    static func make(stats: WeekStats) -> WeekInsight {
        if stats.measuredDays == 0 {
            return WeekInsight(
                title: "Пока нет данных",
                summary: "За неделю нет измерений давления.",
                details: "Добавьте первое измерение, и здесь появится вывод по неделе. \(PressureZone.disclaimer)"
            )
        }
        if stats.normalDays >= 5 {
            return WeekInsight(
                title: "Спокойная неделя",
                summary: "Давление в норме \(stats.normalDays) из 7 дней.",
                details: "Большинство измерений за неделю попали в зону нормы по справочной шкале. "
                    + "Продолжайте измерять в одно и то же время. \(PressureZone.disclaimer)"
            )
        }
        return WeekInsight(
            title: "Неделя с колебаниями",
            summary: "Давление в норме \(stats.normalDays) из 7 дней.",
            details: "Часть значений за неделю выше нормы по справочной шкале. Отмечайте контекст измерений. "
                + "Если значения повторяются, обсудите их с врачом. \(PressureZone.disclaimer)"
        )
    }
}
