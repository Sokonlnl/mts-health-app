import Foundation
import Observation

/// Общее хранилище состояния данных для обоих экранов.
@MainActor
@Observable
final class HealthStore {
    enum LoadState: Equatable {
        case loading
        case loaded
        case failed(String)
    }

    private(set) var state: LoadState = .loading
    private(set) var data: HealthData = .empty
    private(set) var lastSync: Date?

    @ObservationIgnored private let repository: HealthRepository
    @ObservationIgnored private var isLoading = false

    init(repository: HealthRepository) {
        self.repository = repository
    }

    var screenState: ScreenState {
        switch state {
        case .loading: return .loading
        case .failed(let message): return .error(message)
        case .loaded: return data.isEmpty ? .empty : .content
        }
    }

    /// Первая загрузка. Повторные вызовы ничего не делают.
    func loadIfNeeded() async {
        guard state == .loading else { return }
        await load()
    }

    /// Загрузка или повтор после ошибки.
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        state = .loading
        do {
            data = try await repository.load()
            lastSync = Date()
            state = .loaded
        } catch is CancellationError {
            return
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Добавляет измерение в начало истории.
    func add(_ measurement: PressureMeasurement) {
        var updated = data.pressure
        updated.append(measurement)
        updated.sort { $0.date > $1.date }
        data.pressure = updated
    }
}
