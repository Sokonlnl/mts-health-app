import XCTest
@testable import HealthMonitor

@MainActor
final class PressureViewModelTests: XCTestCase {
    private func makeViewModel(
        pressure: [PressureMeasurement] = TestData.periodSample
    ) async -> (PressureViewModel, HealthStore) {
        let store = HealthStore(repository: StubRepository(data: TestData.healthData(pressure: pressure)))
        let viewModel = PressureViewModel(store: store, now: { TestClock.now })
        await viewModel.load()
        return (viewModel, store)
    }

    // MARK: - Смена периода

    private func summary(_ period: PressurePeriod, _ viewModel: PressureViewModel) -> PressureSummary {
        viewModel.period = period
        return viewModel.summary
    }

    func testDefaultPeriodIsWeek() async {
        let (viewModel, _) = await makeViewModel()
        XCTAssertEqual(viewModel.period, .week)
    }

    func testPeriodDayShowsOnlyLastDay() async {
        let (viewModel, _) = await makeViewModel()
        let value = summary(.day, viewModel)
        XCTAssertEqual(value.count, 1)
        XCTAssertEqual(value.latest?.id, "a")
        XCTAssertEqual(value.systolicRange, 120...120)
        XCTAssertEqual(value.averageSystolic, 120)
        XCTAssertEqual(value.averageDiastolic, 80)
    }

    func testPeriodWeek() async {
        let (viewModel, _) = await makeViewModel()
        let value = summary(.week, viewModel)
        XCTAssertEqual(value.count, 2)
        XCTAssertEqual(value.latest?.id, "a")
        XCTAssertEqual(value.systolicRange, 120...140)
        XCTAssertEqual(value.diastolicRange, 80...90)
        XCTAssertEqual(value.averageSystolic, 130)
        XCTAssertEqual(value.averageDiastolic, 85)
    }

    func testPeriodMonth() async {
        let (viewModel, _) = await makeViewModel()
        let value = summary(.month, viewModel)
        XCTAssertEqual(value.count, 3)
        XCTAssertEqual(value.systolicRange, 100...140)
        XCTAssertEqual(value.diastolicRange, 60...90)
        XCTAssertEqual(value.averageSystolic, 120)
        XCTAssertEqual(value.averageDiastolic, 77)   // 230 / 3 = 76,67
    }

    func testPeriodSixMonths() async {
        let (viewModel, _) = await makeViewModel()
        let value = summary(.sixMonths, viewModel)
        XCTAssertEqual(value.count, 4)
        XCTAssertEqual(value.latest?.id, "a")
        XCTAssertEqual(value.systolicRange, 100...160)
        XCTAssertEqual(value.diastolicRange, 60...100)
        XCTAssertEqual(value.averageSystolic, 130)
        XCTAssertEqual(value.averageDiastolic, 83)   // 330 / 4 = 82,5, округление к большему
    }

    func testPeriodChangeUpdatesTextsButNotOverallLatest() async {
        let (viewModel, _) = await makeViewModel()
        viewModel.period = .day
        let dayRange = viewModel.rangeText
        let dayAverage = viewModel.averageText
        let dayLatest = viewModel.latestValueText

        viewModel.period = .sixMonths
        XCTAssertNotEqual(viewModel.rangeText, dayRange)
        XCTAssertNotEqual(viewModel.averageText, dayAverage)
        XCTAssertEqual(viewModel.latestValueText, dayLatest, "Крупное значение не зависит от периода")
    }

    func testPeriodWithoutDataGivesDashes() async {
        let old = [TestData.measurement("old", systolic: 120, diastolic: 80, secondsAgo: 100 * TestClock.day)]
        let (viewModel, _) = await makeViewModel(pressure: old)
        viewModel.period = .week
        XCTAssertEqual(viewModel.summary.count, 0)
        XCTAssertEqual(viewModel.rangeText, AppFormat.dash)
        XCTAssertEqual(viewModel.averageText, AppFormat.dash)
        XCTAssertTrue(viewModel.periodMeasurements.isEmpty)
    }

    // MARK: - Модели для View

    func testAdviceDeckDismissAndRefresh() async {
        let store = HealthStore(repository: MockHealthRepository(delayNanoseconds: 0))
        let viewModel = PressureViewModel(store: store)
        await viewModel.load()
        let total = viewModel.adviceCards.count
        XCTAssertGreaterThan(total, 0)
        XCTAssertTrue(viewModel.hasAdvice)
        viewModel.dismissAdvice()
        XCTAssertEqual(viewModel.adviceCards.count, total - 1)
        for _ in 0..<total { viewModel.dismissAdvice() }
        XCTAssertTrue(viewModel.adviceCards.isEmpty)
        viewModel.refreshAdvice()
        XCTAssertEqual(viewModel.adviceCards.count, total)
    }

    func testZonePlatesMarkCurrentZoneAndPlaceholder() async {
        let (viewModel, _) = await makeViewModel(
            pressure: [TestData.measurement("p", systolic: 134, diastolic: 86, secondsAgo: 60)]
        )
        XCTAssertEqual(viewModel.zonePlates.filter(\.isCurrent).map(\.title), [PressureZone.elevated.title])
        XCTAssertFalse(viewModel.latestIsPlaceholder)
        let (empty, _) = await makeViewModel(pressure: [])
        XCTAssertTrue(empty.latestIsPlaceholder)
        XCTAssertTrue(empty.zonePlates.allSatisfy { !$0.isCurrent })
    }
}
