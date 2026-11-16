import XCTest
@testable import HealthMonitor

/// Регрессия QA-001: экран давления, открытый сразу (initialPath), навсегда оставался в loading,
/// потому что загрузку начал .task главного экрана, а его отмена оставляла state == .loading
/// и никто не перезапускал загрузку.
final class HealthStoreLoadingTests: XCTestCase {
    @MainActor
    func testCancelledFirstLoaderDoesNotLeaveStoreStuckInLoading() async {
        let store = HealthStore(
            repository: MockHealthRepository(scenario: .normal, delayNanoseconds: 200_000_000)
        )

        // Первый загрузчик (как .task главного экрана), который потом отменяется (уход с экрана).
        let first = Task { await store.loadIfNeeded() }
        try? await Task.sleep(nanoseconds: 50_000_000)

        // Второй загрузчик (как .task экрана давления) запускается, пока загрузка идёт.
        let second = Task { await store.loadIfNeeded() }
        first.cancel()
        await first.value
        await second.value

        // Допускаем, что завершение придёт чуть позже, но состояние обязано стать loaded.
        for _ in 0..<20 where store.state == .loading {
            try? await Task.sleep(nanoseconds: 50_000_000)
        }
        XCTAssertEqual(store.state, .loaded, "Загрузка не должна зависать после отмены первого загрузчика")
        XCTAssertEqual(store.screenState, .content)
    }
}
