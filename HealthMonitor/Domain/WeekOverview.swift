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

/// Сколько дней из последних 7 были с измерением и сколько из них в норме.
struct WeekStats: Equatable {
    let normalDays: Int
    let measuredDays: Int
}

enum WeekOverview {
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

/// Расширенный вывод по неделе («Подробнее» в верхнем блоке). Без диагнозов.
struct WeekInsight: Equatable {
    let details: String

    static func make(stats: WeekStats) -> WeekInsight {
        if stats.measuredDays == 0 {
            return WeekInsight(
                details: "Добавьте первое измерение, и здесь появится вывод по неделе. \(PressureZone.disclaimer)"
            )
        }
        let days = "Давление в норме \(stats.normalDays) из \(stats.measuredDays) измеренных дней. "
        if stats.normalDays >= 5 {
            return WeekInsight(
                details: days + "Большинство измерений за неделю попали в зону нормы по справочной шкале. "
                    + "Продолжайте измерять в одно и то же время. \(PressureZone.disclaimer)"
            )
        }
        return WeekInsight(
            details: days + "Часть значений за неделю выше нормы по справочной шкале. Отмечайте контекст измерений. "
                + "Если значения повторяются, обсудите их с врачом. \(PressureZone.disclaimer)"
        )
    }
}
