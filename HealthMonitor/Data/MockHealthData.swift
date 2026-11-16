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
                    context: .morning
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
                        context: .evening
                    )
                )
            }
        }
        return result.sorted { $0.date > $1.date }
    }

    static func make(now: Date) -> HealthData {
        HealthData(
            pressure: pressure(now: now),
            pulse: MetricReading(
                latest: 68,
                series: [66, 68, 65, 70, 67, 64, 69, 66, 68, 71, 65, 67, 66, 68],
                daysInNorm: 7
            ),
            weight: MetricReading(
                latest: 72.4,
                series: [73.2, 73.1, 73.0, 72.9, 72.9, 72.8, 72.7, 72.6, 72.6, 72.5, 72.5, 72.4, 72.4, 72.4],
                daysInNorm: 5
            ),
            glucose: .empty
        )
    }
}
