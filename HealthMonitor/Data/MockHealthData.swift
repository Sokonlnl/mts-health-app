import Foundation

/// Детерминированные моковые данные: никакого random, всё считается от `now`.
enum MockHealthData {
    private static let systolic = [122, 126, 118, 131, 124, 119, 128, 137, 121, 125, 133, 117, 123, 142]
    private static let diastolic = [79, 82, 76, 84, 80, 77, 83, 88, 78, 81, 86, 74, 79, 92]
    private static let day: TimeInterval = 86_400

    /// Измерения давления примерно за 6 месяцев, новые первыми.
    static func pressure(now: Date) -> [PressureMeasurement] {
        var result: [PressureMeasurement] = []
        for index in 0..<180 {
            let slot = index % systolic.count
            let morning = now.addingTimeInterval(-Double(index) * day - 1_800)
            result.append(
                PressureMeasurement(
                    id: "morning-\(index)",
                    date: morning,
                    systolic: systolic[slot],
                    diastolic: diastolic[slot],
                    pulse: 60 + (index * 7) % 15,
                    context: MeasurementContext.matching(morning)
                )
            )
            if index < 45 {
                let evening = now.addingTimeInterval(-Double(index) * day - 36_000)
                result.append(
                    PressureMeasurement(
                        id: "evening-\(index)",
                        date: evening,
                        systolic: systolic[slot] - 3,
                        diastolic: diastolic[slot] - 2,
                        pulse: 64 + (index * 5) % 13,
                        context: MeasurementContext.matching(evening)
                    )
                )
            }
        }
        return result.sorted { $0.date > $1.date }
    }

    /// Справочные советы. Без диагнозов и назначений.
    static let advice = [
        Advice(
            id: "walk",
            title: "Небольшая прогулка — забота о себе",
            text: "Начните с 10 минут на свежем воздухе в комфортном темпе.",
            zones: [.normal]
        ),
        Advice(
            id: "water",
            title: "Стакан воды в течение дня",
            text: "Небольшие порции воды помогают не забывать о питьевом режиме."
        ),
        Advice(
            id: "routine",
            title: "Измеряйте давление в одно время",
            text: "Так значения легче сравнивать. Перед измерением посидите спокойно пять минут.",
            zones: [.elevated]
        ),
        Advice(
            id: "rest",
            title: "Дайте себе немного покоя",
            text: "Посидите спокойно несколько минут и измерьте давление ещё раз.",
            zones: [.high]
        )
    ]

    static func make(now: Date) -> HealthData {
        HealthData(
            pressure: pressure(now: now),
            pulse: MetricReading(latest: 68),
            weight: MetricReading(latest: 72.4),
            glucose: MetricReading(latest: 5.4),
            advice: advice
        )
    }
}
