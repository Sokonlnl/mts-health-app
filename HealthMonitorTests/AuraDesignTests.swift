import XCTest
@testable import HealthMonitor

@MainActor
final class AuraDesignTests: XCTestCase {
    private func makePressure(pressure: [PressureMeasurement]) async -> PressureViewModel {
        let store = HealthStore(repository: StubRepository(data: TestData.healthData(pressure: pressure)))
        let viewModel = PressureViewModel(store: store, now: { TestClock.now })
        await viewModel.load()
        return viewModel
    }

    // MARK: - Домен

    func testHealthStateFromZone() {
        XCTAssertEqual(HealthState(zone: .normal), .normal)
        XCTAssertEqual(HealthState(zone: .elevated).tone, .caution)
        XCTAssertEqual(HealthState(zone: .high).tone, .critical)
        XCTAssertEqual(HealthState.noData.tone, .neutral)
    }

    // MARK: - Экран давления

    func testInNormTextAndAverageZone() async {
        let viewModel = await makePressure(pressure: TestData.periodSample)
        XCTAssertEqual(viewModel.inNormText, "В норме 1 из 2")
        XCTAssertNotNil(viewModel.averageZone)
    }

    func testLatestStateWithoutMeasurements() async {
        let viewModel = await makePressure(pressure: [])
        XCTAssertEqual(viewModel.latestState, .noData)
        XCTAssertEqual(viewModel.latestStatusText, AppFormat.noData)
        XCTAssertEqual(viewModel.latestUnitText, AppUnit.pressure)
    }

    func testLatestUnitTextIncludesPulse() async {
        let sample = TestData.measurement("a", systolic: 120, diastolic: 80, secondsAgo: 0, pulse: 68)
        let viewModel = await makePressure(pressure: [sample])
        XCTAssertEqual(viewModel.latestUnitText, "мм рт. ст. · пульс 68")
    }

    func testAverageToneFollowsAverageZone() async {
        let normal = await makePressure(pressure: [TestData.measurement("a", systolic: 118, diastolic: 76, secondsAgo: 60)])
        XCTAssertEqual(normal.averageTone, .positive)
        let high = await makePressure(pressure: [TestData.measurement("b", systolic: 150, diastolic: 95, secondsAgo: 60)])
        XCTAssertEqual(high.averageTone, .critical)
        let none = await makePressure(pressure: [])
        XCTAssertEqual(none.averageTone, .neutral, "Без измерений тон нейтральный")
    }

    func testPeriodEmptinessAndMessages() async {
        let old = [TestData.measurement("old", systolic: 120, diastolic: 80, secondsAgo: 100 * TestClock.day)]
        let viewModel = await makePressure(pressure: old)
        viewModel.period = .week
        XCTAssertFalse(viewModel.hasPeriodMeasurements)
        XCTAssertEqual(viewModel.emptyPeriodMessage, "За выбранный период измерений нет.")
        viewModel.period = .sixMonths
        XCTAssertTrue(viewModel.hasPeriodMeasurements)
        XCTAssertFalse(viewModel.emptyMessage.isEmpty)
    }

    func testHeroHeightIsCompactOnlyOnError() async {
        let ok = await makePressure(pressure: [])
        XCTAssertEqual(ok.heroHeight, Size.pressureHeroHeight)
        let failing = HealthStore(repository: MockHealthRepository(scenario: .failure, delayNanoseconds: 0))
        let error = PressureViewModel(store: failing, now: { TestClock.now })
        await error.load()
        XCTAssertEqual(error.heroHeight, Size.heroCompactHeight)
    }
}
