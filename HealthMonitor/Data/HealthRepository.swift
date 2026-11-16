import Foundation

enum HealthRepositoryError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        "Сервис временно недоступен. Проверьте соединение и повторите попытку."
    }
}

/// Единственный источник данных приложения.
protocol HealthRepository: Sendable {
    func load() async throws -> HealthData
}

/// Сценарий мока: нужен для демонстрации состояний и UI-тестов.
enum MockScenario: Equatable {
    case normal
    case empty
    case failure
    case neverLoads
}

struct MockHealthRepository: HealthRepository {
    var scenario: MockScenario = .normal
    var now = Date()
    var delayNanoseconds: UInt64 = 300_000_000

    func load() async throws -> HealthData {
        switch scenario {
        case .normal:
            try await Task.sleep(nanoseconds: delayNanoseconds)
            return MockHealthData.make(now: now)
        case .empty:
            try await Task.sleep(nanoseconds: delayNanoseconds)
            return .empty
        case .failure:
            try await Task.sleep(nanoseconds: delayNanoseconds)
            throw HealthRepositoryError.unavailable
        case .neverLoads:
            try await Task.sleep(nanoseconds: 3_600_000_000_000)
            return .empty
        }
    }
}
