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
