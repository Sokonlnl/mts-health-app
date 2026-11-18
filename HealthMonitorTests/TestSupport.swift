import Foundation
@testable import HealthMonitor

/// Общие помощники для unit-тестов: фиксированное «сейчас» и репозитории-заглушки.
enum TestClock {
    /// Около полудня по UTC, чтобы сдвиги в сутки не пересекали границу календарного дня.
    static let now = Date(timeIntervalSince1970: 1_700_050_000)
    static let day: TimeInterval = 86_400
}

enum TestData {
    static func measurement(
        _ id: String,
        systolic: Int,
        diastolic: Int,
        secondsAgo: TimeInterval,
        pulse: Int? = 70
    ) -> PressureMeasurement {
        PressureMeasurement(
            id: id,
            date: TestClock.now.addingTimeInterval(-secondsAgo),
            systolic: systolic,
            diastolic: diastolic,
            pulse: pulse,
            context: nil
        )
    }

    /// Четыре измерения на разной глубине: 1 ч, 2 суток, 20 суток, 100 суток назад. Новые первыми.
    static var periodSample: [PressureMeasurement] {
        [
            measurement("a", systolic: 120, diastolic: 80, secondsAgo: 3_600),
            measurement("b", systolic: 140, diastolic: 90, secondsAgo: 2 * TestClock.day),
            measurement("c", systolic: 100, diastolic: 60, secondsAgo: 20 * TestClock.day),
            measurement("d", systolic: 160, diastolic: 100, secondsAgo: 100 * TestClock.day)
        ]
    }

    static func healthData(pressure: [PressureMeasurement]) -> HealthData {
        HealthData(
            pressure: pressure,
            pulse: MetricReading(latest: 68),
            weight: .empty,
            glucose: .empty
        )
    }
}

/// Репозиторий, отдающий заранее заданные данные без задержки.
struct StubRepository: HealthRepository {
    let data: HealthData

    func load() async throws -> HealthData { data }
}

/// Репозиторий: первые `failures` вызовов бросают ошибку, дальше отдаёт данные.
final class FlakyRepository: HealthRepository, @unchecked Sendable {
    private let lock = NSLock()
    private var remainingFailures: Int
    private var calls = 0
    private let data: HealthData

    init(failures: Int, data: HealthData) {
        self.remainingFailures = failures
        self.data = data
    }

    /// Сколько раз вызывали `load()`.
    var loadCalls: Int {
        lock.lock()
        defer { lock.unlock() }
        return calls
    }

    func load() async throws -> HealthData {
        lock.lock()
        calls += 1
        let shouldFail = remainingFailures > 0
        if shouldFail { remainingFailures -= 1 }
        lock.unlock()
        if shouldFail { throw HealthRepositoryError.unavailable }
        return data
    }
}
