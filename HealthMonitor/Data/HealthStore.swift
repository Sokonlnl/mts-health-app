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
    @ObservationIgnored private var loadTask: Task<Void, Never>?

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

    /// Первая загрузка. Если загрузка уже идёт, ждёт её. Если данные загружены, ничего не делает.
    func loadIfNeeded() async {
        if let loadTask {
            await loadTask.value
            return
        }
        guard state == .loading else { return }
        await startLoading()
    }

    /// Загрузка или повтор после ошибки. Если загрузка уже идёт, ждёт её, а не запускает вторую.
    func load() async {
        if let loadTask {
            await loadTask.value
            return
        }
        await startLoading()
    }

    /// Добавляет измерение в начало истории.
    func add(_ measurement: PressureMeasurement) {
        var updated = data.pressure
        updated.append(measurement)
        updated.sort { $0.date > $1.date }
        data.pressure = updated
    }

    // MARK: - Загрузка

    /// Загрузка идёт в неструктурированной `Task`: отмена `.task` вызывающего экрана её не отменяет,
    /// поэтому `state` не может остаться `.loading` без загрузчика (QA-001).
    private func startLoading() async {
        state = .loading
        let repository = repository
        let task = Task { [weak self] in
            let result: Result<HealthData, any Error>
            do {
                result = .success(try await repository.load())
            } catch {
                result = .failure(error)
            }
            self?.finishLoading(result)
        }
        loadTask = task
        await task.value
    }

    private func finishLoading(_ result: Result<HealthData, any Error>) {
        loadTask = nil
        switch result {
        case .success(let loaded):
            data = loaded
            lastSync = Date()
            state = .loaded
        case .failure(let error):
            state = .failed(error.localizedDescription)
        }
    }
}
