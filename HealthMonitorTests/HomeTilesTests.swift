import XCTest
@testable import HealthMonitor

@MainActor
final class HomeTilesTests: XCTestCase {
    private func makeViewModel(pressure: [PressureMeasurement]) async -> HomeViewModel {
        let store = HealthStore(repository: StubRepository(data: TestData.healthData(pressure: pressure)))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        await viewModel.load()
        return viewModel
    }

    func testTilesOrderAndPressureStatus() async {
        let viewModel = await makeViewModel(
            pressure: [TestData.measurement("a", systolic: 122, diastolic: 79, secondsAgo: 0)]
        )
        let tiles = viewModel.tiles
        XCTAssertEqual(tiles.map(\.kind), [.pressure, .pulse, .weight])
        XCTAssertEqual(tiles[0].valueText, "122/79")
        XCTAssertEqual(tiles[0].statusText, PressureZone.normal.title)
        XCTAssertNil(tiles[1].statusText, "Статус зоны только у давления")
        XCTAssertEqual(viewModel.glowState, .normal)
    }

    func testEmptyPressureTileHasNoValueAndNoDataStatus() async {
        let viewModel = await makeViewModel(pressure: [])
        let tile = viewModel.tiles[0]
        XCTAssertNil(tile.valueText)
        XCTAssertEqual(tile.statusText, AppFormat.noData)
        XCTAssertEqual(viewModel.glowState, .noData)
    }

    func testElevatedPressureChangesGlowState() async {
        let viewModel = await makeViewModel(
            pressure: [TestData.measurement("a", systolic: 134, diastolic: 86, secondsAgo: 0)]
        )
        XCTAssertEqual(viewModel.glowState, .elevated)
        XCTAssertEqual(viewModel.tiles[0].statusText, PressureZone.elevated.title)
    }

    func testPulseAndWeightCardsAreSolidPositiveAndOnlyPulseHasSparkline() async {
        let viewModel = await makeViewModel(pressure: [])
        let pulse = viewModel.card(.pulse)
        XCTAssertEqual(pulse.tone, .positive)
        XCTAssertTrue(pulse.showsSparkline)
        let emptyWeight = viewModel.card(.weight)
        XCTAssertEqual(emptyWeight.tone, .neutral, "Нет данных веса: статус нейтральный")
        XCTAssertFalse(emptyWeight.showsSparkline)

        var data = TestData.healthData(pressure: [])
        data.weight = MetricReading(latest: 74.2, series: [74.6, 74.2], daysInNorm: 7)
        let withWeight = HomeViewModel(store: HealthStore(repository: StubRepository(data: data)), now: { TestClock.now })
        await withWeight.load()
        XCTAssertEqual(withWeight.card(.weight).tone, .positive)
        XCTAssertFalse(withWeight.card(.weight).showsSparkline)
    }

    // MARK: - Вид экрана

    func testLoadingLayout() {
        let store = HealthStore(repository: StubRepository(data: .empty))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(viewModel.showsInsight)
        XCTAssertEqual(viewModel.tilesTop, Size.homeTilesTop)
    }

    func testContentLayoutShowsInsightWithFullTop() async {
        let viewModel = await makeViewModel(pressure: [TestData.measurement("a", systolic: 120, diastolic: 80, secondsAgo: 60)])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showsInsight)
        XCTAssertEqual(viewModel.tilesTop, Size.homeTilesTop)
    }

    func testEmptyAndErrorLayoutHaveCompactTopWithoutInsight() async {
        let empty = HomeViewModel(store: HealthStore(repository: StubRepository(data: .empty)), now: { TestClock.now })
        await empty.load()
        XCTAssertEqual(empty.screenState, .empty)
        XCTAssertFalse(empty.showsInsight)
        XCTAssertEqual(empty.tilesTop, Size.homeCompactTop)

        let failing = HealthStore(repository: MockHealthRepository(scenario: .failure, delayNanoseconds: 0))
        let error = HomeViewModel(store: failing, now: { TestClock.now })
        await error.load()
        XCTAssertFalse(error.showsInsight)
        XCTAssertEqual(error.tilesTop, Size.homeCompactTop)
    }
}
