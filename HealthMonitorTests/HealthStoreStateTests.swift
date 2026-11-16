import XCTest
@testable import HealthMonitor

/// Состояния HealthStore: loading, loaded, empty, failure и повтор после ошибки.
@MainActor
final class HealthStoreStateTests: XCTestCase {
    private var sample: HealthData { TestData.healthData(pressure: TestData.periodSample) }

    func testInitialStateIsLoading() {
        let store = HealthStore(repository: StubRepository(data: sample))
        XCTAssertEqual(store.state, .loading)
        XCTAssertEqual(store.screenState, .loading)
        XCTAssertNil(store.lastSync)
    }

    func testLoadedState() async {
        let store = HealthStore(repository: StubRepository(data: sample))
        await store.loadIfNeeded()
        XCTAssertEqual(store.state, .loaded)
        XCTAssertEqual(store.screenState, .content)
        XCTAssertEqual(store.data.pressure.count, TestData.periodSample.count)
        XCTAssertNotNil(store.lastSync)
    }

    func testEmptyState() async {
        let store = HealthStore(repository: StubRepository(data: .empty))
        await store.loadIfNeeded()
        XCTAssertEqual(store.state, .loaded)
        XCTAssertEqual(store.screenState, .empty)
    }

    func testFailureState() async {
        let store = HealthStore(repository: FlakyRepository(failures: 1, data: sample))
        await store.loadIfNeeded()
        let message = HealthRepositoryError.unavailable.localizedDescription
        XCTAssertEqual(store.state, .failed(message))
        XCTAssertEqual(store.screenState, .error(message))
        XCTAssertNil(store.lastSync)
        XCTAssertTrue(store.data.pressure.isEmpty)
    }

    func testRetryAfterFailureLoadsData() async {
        let store = HealthStore(repository: FlakyRepository(failures: 1, data: sample))
        await store.loadIfNeeded()
        XCTAssertNotEqual(store.screenState, .content)

        await store.load()
        XCTAssertEqual(store.state, .loaded)
        XCTAssertEqual(store.screenState, .content)
        XCTAssertFalse(store.data.pressure.isEmpty)
        XCTAssertNotNil(store.lastSync)
    }

    func testRepeatedFailuresKeepErrorUntilSuccess() async {
        let store = HealthStore(repository: FlakyRepository(failures: 2, data: sample))
        await store.load()
        await store.load()
        if case .failed = store.state {} else { XCTFail("Ожидалась ошибка после второй неудачи") }
        await store.load()
        XCTAssertEqual(store.state, .loaded)
    }

    func testLoadIfNeededDoesNotReloadLoadedData() async {
        let repository = FlakyRepository(failures: 0, data: sample)
        let store = HealthStore(repository: repository)
        await store.loadIfNeeded()
        store.add(TestData.measurement("extra", systolic: 110, diastolic: 70, secondsAgo: 10))
        await store.loadIfNeeded()
        XCTAssertEqual(store.data.pressure.first?.id, "extra", "Повторный loadIfNeeded не должен затирать данные")
    }

    func testRetryViaViewModelsUsesReload() async {
        let store = HealthStore(repository: FlakyRepository(failures: 1, data: sample))
        let viewModel = PressureViewModel(store: store, now: { TestClock.now })
        await viewModel.load()
        XCTAssertNotEqual(viewModel.screenState, .content)
        await viewModel.reload()
        XCTAssertEqual(viewModel.screenState, .content)
    }
}
