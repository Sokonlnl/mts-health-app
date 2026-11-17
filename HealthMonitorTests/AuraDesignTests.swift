import XCTest
@testable import HealthMonitor

@MainActor
final class AuraDesignTests: XCTestCase {
    private func makeHome(pressure: [PressureMeasurement]) async -> HomeViewModel {
        let store = HealthStore(repository: StubRepository(data: TestData.healthData(pressure: pressure)))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        await viewModel.load()
        return viewModel
    }

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

    func testPressureScaleFractionsSumToOne() {
        let sum = PressureZone.allCases.map { PressureScale.fraction(for: $0) }.reduce(0, +)
        XCTAssertEqual(sum, 1, accuracy: 0.0001)
    }

    func testPressureScaleProgressFollowsZones() {
        let normal = PressureScale.progress(systolic: 118, diastolic: 76)
        let elevated = PressureScale.progress(systolic: 134, diastolic: 80)
        let high = PressureScale.progress(systolic: 150, diastolic: 95)
        XCTAssertLessThan(normal, 0.5)
        XCTAssertTrue(elevated >= 0.5 && elevated < 0.625)
        XCTAssertGreaterThanOrEqual(high, 0.625)
    }

    func testPressureScaleUsesWorseOfTwoValues() {
        let byDiastolic = PressureScale.progress(systolic: 118, diastolic: 88)
        XCTAssertGreaterThanOrEqual(byDiastolic, 0.5)
    }

    func testWeekBarsCoverSevenDaysEndingToday() {
        let items = [
            TestData.measurement("a", systolic: 120, diastolic: 80, secondsAgo: 3_600),
            TestData.measurement("b", systolic: 135, diastolic: 86, secondsAgo: 2 * TestClock.day)
        ]
        let bars = WeekBars.make(measurements: items, now: TestClock.now)
        XCTAssertEqual(bars.count, 7)
        XCTAssertEqual(bars.last?.isToday, true)
        XCTAssertEqual(bars.last?.systolic, 120)
        XCTAssertEqual(bars[4].isElevated, true)
        XCTAssertEqual(bars[0].ratio, 0)
        XCTAssertGreaterThan(bars[4].ratio, bars[6].ratio)
    }

    // MARK: - Главный экран

    func testHeroForPressureUsesLatestZone() async {
        let viewModel = await makeHome(pressure: [TestData.measurement("a", systolic: 134, diastolic: 86, secondsAgo: 60)])
        XCTAssertEqual(viewModel.hero.state, .elevated)
        XCTAssertEqual(viewModel.hero.valueText, "134/86")
        XCTAssertNotNil(viewModel.hero.markerProgress)
        XCTAssertEqual(viewModel.hero.accessibilityText, "Давление 134 на 86, повышенное")
    }

    func testHeroWithoutPressureIsNoData() async {
        let viewModel = await makeHome(pressure: [])
        XCTAssertEqual(viewModel.hero.state, .noData)
        XCTAssertEqual(viewModel.hero.valueText, AppFormat.emptyPressureValue)
        XCTAssertNil(viewModel.hero.markerProgress)
    }

    func testSelectingKindChangesHeroAndCollapsesInsight() async {
        let viewModel = await makeHome(pressure: [TestData.measurement("a", systolic: 120, diastolic: 80, secondsAgo: 60)])
        viewModel.toggleInsight()
        viewModel.select(.pulse)
        XCTAssertEqual(viewModel.selectedKind, .pulse)
        XCTAssertEqual(viewModel.hero.valueText, "68")
        XCTAssertFalse(viewModel.isInsightExpanded)
        viewModel.select(.glucose)
        XCTAssertEqual(viewModel.hero.state, .noData)
        XCTAssertNil(viewModel.headline.details)
    }

    func testPillsMarkSelectedKind() async {
        let viewModel = await makeHome(pressure: [])
        XCTAssertEqual(viewModel.pills.count, 4)
        XCTAssertEqual(viewModel.pills.filter(\.isSelected).map(\.kind), [.pressure])
    }

    // MARK: - Экран давления

    func testStepFocusedFillsClampsAndChangesValue() async {
        let viewModel = await makePressure(pressure: [])
        viewModel.openSheet()
        viewModel.stepFocused(by: 1)
        XCTAssertEqual(viewModel.draft.systolicText, "120")
        viewModel.stepFocused(by: 1)
        XCTAssertEqual(viewModel.draft.systolicText, "121")
        viewModel.draft.systolicText = "250"
        viewModel.stepFocused(by: 1)
        XCTAssertEqual(viewModel.draft.systolicText, "250")
    }

    func testInNormTextAndAverageZone() async {
        let viewModel = await makePressure(pressure: TestData.periodSample)
        XCTAssertEqual(viewModel.inNormText, "В норме 1 из 2")
        XCTAssertNotNil(viewModel.averageZone)
    }

    func testLatestStateWithoutMeasurements() async {
        let viewModel = await makePressure(pressure: [])
        XCTAssertEqual(viewModel.latestState, .noData)
        XCTAssertEqual(viewModel.latestStatusText, AppFormat.noData)
        XCTAssertEqual(viewModel.orbUnitText, AppUnit.pressure)
    }
}
