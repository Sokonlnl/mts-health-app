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
        let tiles = [viewModel.pressureTile] + viewModel.sideTiles
        XCTAssertEqual(tiles.map(\.kind), [.pressure, .pulse, .weight])
        XCTAssertEqual(tiles[0].valueText, "122/79")
        XCTAssertEqual(tiles[0].statusText, PressureZone.normal.title)
        XCTAssertNil(tiles[1].statusText, "Статус зоны только у давления")
        XCTAssertEqual(viewModel.glowState, .normal)
    }

    func testEmptyPressureTileHasNoValueAndNoDataStatus() async {
        let viewModel = await makeViewModel(pressure: [])
        let tile = viewModel.pressureTile
        XCTAssertNil(tile.valueText)
        XCTAssertEqual(tile.statusText, AppFormat.noData)
        XCTAssertEqual(viewModel.glowState, .noData)
    }

    func testElevatedPressureChangesGlowState() async {
        let viewModel = await makeViewModel(
            pressure: [TestData.measurement("a", systolic: 134, diastolic: 86, secondsAgo: 0)]
        )
        XCTAssertEqual(viewModel.glowState, .elevated)
        XCTAssertEqual(viewModel.pressureTile.statusText, PressureZone.elevated.title)
    }

    func testListCardsAreSolidPulseAndGlassGlucoseWithoutBentoRepeats() async {
        let viewModel = await makeViewModel(pressure: [])
        XCTAssertEqual(viewModel.listCards.map(\.kind), [.pulse, .glucose], "Пульс и вес из бенто не повторяются")
        XCTAssertEqual(viewModel.listCards.map(\.surface), [.solid, .glass])
        XCTAssertEqual(viewModel.card(.pulse).tone, .positive)
        XCTAssertEqual(viewModel.card(.weight).tone, .neutral, "Нет данных веса: статус нейтральный")
    }

    func testSurfaceAndSparklineStyleComeFromKindForDataAndEmptyCards() async {
        let empty = MetricCardModel.empty(.pulse, unit: AppUnit.pulse)
        XCTAssertEqual(empty.surface, .solid)
        XCTAssertEqual(empty.sparklineStyle, .marker)
        let withData = await makeViewModel(pressure: []).card(.pulse)
        XCTAssertNotNil(withData.valueText)
        XCTAssertEqual(withData.surface, .solid)
        XCTAssertEqual(withData.sparklineStyle, .marker)
        for kind in [MetricKind.pressure, .weight, .glucose] {
            let card = MetricCardModel.empty(kind, unit: "")
            XCTAssertEqual(card.surface, .glass)
            XCTAssertEqual(card.sparklineStyle, .line)
        }
    }

    func testValueCaptionForEmptyAndFilledCards() async {
        let empty = MetricCardModel.empty(.glucose, unit: AppUnit.glucose)
        XCTAssertEqual(empty.valueCaption, "ммоль/л · измерений пока нет")
        let viewModel = await makeViewModel(pressure: [])
        let pulse = viewModel.card(.pulse)
        XCTAssertNotNil(pulse.valueText)
        XCTAssertEqual(pulse.valueCaption, AppUnit.pulse)
    }

    func testSideTilesHaveNoStatus() async {
        var data = TestData.healthData(pressure: [])
        data.weight = MetricReading(latest: 74.2, series: [74.6, 74.2], daysInNorm: 7)
        let viewModel = HomeViewModel(store: HealthStore(repository: StubRepository(data: data)), now: { TestClock.now })
        await viewModel.load()
        XCTAssertEqual(viewModel.sideTiles.map(\.kind), [.pulse, .weight])
        XCTAssertEqual(viewModel.sideTiles[1].valueText, "74,2")
        XCTAssertTrue(viewModel.sideTiles.allSatisfy { $0.statusText == nil })
    }

    // MARK: - Вид экрана

    func testLoadingLayout() {
        let store = HealthStore(repository: StubRepository(data: .empty))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(viewModel.showsInsight)
        XCTAssertEqual(viewModel.columnTop, Size.homeColumnTop)
    }

    func testContentLayoutShowsInsightWithFullTop() async {
        let viewModel = await makeViewModel(pressure: [TestData.measurement("a", systolic: 120, diastolic: 80, secondsAgo: 60)])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showsInsight)
        XCTAssertEqual(viewModel.columnTop, Size.homeColumnTop)
    }

    func testEmptyAndErrorLayoutHaveCompactTopWithoutInsight() async {
        let empty = HomeViewModel(store: HealthStore(repository: StubRepository(data: .empty)), now: { TestClock.now })
        await empty.load()
        XCTAssertEqual(empty.screenState, .empty)
        XCTAssertFalse(empty.showsInsight)
        XCTAssertEqual(empty.columnTop, Size.homeCompactTop)

        let failing = HealthStore(repository: MockHealthRepository(scenario: .failure, delayNanoseconds: 0))
        let error = HomeViewModel(store: failing, now: { TestClock.now })
        await error.load()
        XCTAssertFalse(error.showsInsight)
        XCTAssertEqual(error.columnTop, Size.homeCompactTop)
    }
}
