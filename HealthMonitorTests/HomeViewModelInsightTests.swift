import XCTest
@testable import HealthMonitor

@MainActor
final class HomeViewModelInsightTests: XCTestCase {
    /// Семь суток подряд по одному нормальному измерению: «Спокойная неделя».
    private var calmWeek: [PressureMeasurement] {
        (0..<7).map {
            TestData.measurement("d\($0)", systolic: 118, diastolic: 76, secondsAgo: Double($0) * TestClock.day)
        }
    }

    private func makeViewModel(pressure: [PressureMeasurement]) async -> HomeViewModel {
        let store = HealthStore(repository: StubRepository(data: TestData.healthData(pressure: pressure)))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        await viewModel.load()
        return viewModel
    }

    func testInsightIsCollapsedByDefault() async {
        let viewModel = await makeViewModel(pressure: calmWeek)
        XCTAssertFalse(viewModel.isInsightExpanded)
    }

    func testToggleExpandsAndCollapsesInsight() async {
        let viewModel = await makeViewModel(pressure: calmWeek)
        viewModel.toggleInsight()
        XCTAssertTrue(viewModel.isInsightExpanded)
        viewModel.toggleInsight()
        XCTAssertFalse(viewModel.isInsightExpanded)
    }

    func testCalmWeekInsightContent() async {
        let viewModel = await makeViewModel(pressure: calmWeek)
        let insight = viewModel.insight
        XCTAssertTrue(insight.details.contains("7 из 7"))
        XCTAssertTrue(insight.details.contains(PressureZone.disclaimer), "Расширенный вывод содержит оговорку")
    }

    func testInsightCountsMeasuredDaysNotSeven() async {
        let viewModel = await makeViewModel(pressure: Array(calmWeek.prefix(3)))
        XCTAssertTrue(viewModel.insight.details.contains("3 из 3 измеренных дней"))
    }

    func testToggleDoesNotChangeInsightText() async {
        let viewModel = await makeViewModel(pressure: calmWeek)
        let before = viewModel.insight
        viewModel.toggleInsight()
        XCTAssertEqual(viewModel.insight, before)
    }

    func testInsightWithoutMeasurements() async {
        let viewModel = await makeViewModel(pressure: [])
        XCTAssertTrue(viewModel.insight.details.contains("Измерений за неделю пока нет"))
    }
}
