import XCTest
@testable import HealthMonitor

final class HomeDataTests: XCTestCase {
    // Среда, 15 ноября 2023, 12:00 UTC. Календарь приложения берёт локальный часовой пояс,
    // поэтому проверяем только то, что не зависит от пояса.
    private let now = Date(timeIntervalSince1970: 1_700_049_600)

    func testMockDataIsDeterministic() {
        XCTAssertEqual(MockHealthData.make(now: now), MockHealthData.make(now: now))
    }

    func testMockDataCoversAboutSixMonthsNewestFirst() {
        let data = MockHealthData.make(now: now)
        XCTAssertGreaterThan(data.pressure.count, 180)
        XCTAssertEqual(data.pressure, data.pressure.sorted { $0.date > $1.date })
        let oldest = data.pressure.last?.date ?? now
        XCTAssertGreaterThan(now.timeIntervalSince(oldest), 170 * 86_400)
    }

    func testMockGlucoseIsEmpty() {
        let data = MockHealthData.make(now: now)
        XCTAssertNil(data.glucose.latest)
        XCTAssertNotNil(data.pulse.latest)
        XCTAssertNotNil(data.weight.latest)
        XCTAssertFalse(data.isEmpty)
        XCTAssertTrue(HealthData.empty.isEmpty)
    }

    func testWeekStatsOnEmptyData() {
        let stats = WeekOverview.stats(measurements: [], now: now)
        XCTAssertEqual(stats, WeekStats(normalDays: 0, measuredDays: 0))
    }

    func testInsightVariants() {
        XCTAssertEqual(WeekInsight.make(stats: WeekStats(normalDays: 6, measuredDays: 7)).title, "Спокойная неделя")
        XCTAssertEqual(WeekInsight.make(stats: WeekStats(normalDays: 2, measuredDays: 7)).title, "Неделя с колебаниями")
        XCTAssertEqual(WeekInsight.make(stats: WeekStats(normalDays: 0, measuredDays: 0)).title, "Пока нет данных")
    }

    func testFormatting() {
        XCTAssertEqual(AppFormat.pressureValue(122, 79), "122/79")
        XCTAssertEqual(AppFormat.range(118...136), "118–136")
        XCTAssertEqual(AppFormat.range(120...120), "120")
        XCTAssertEqual(AppFormat.range(nil), "–")
        XCTAssertEqual(AppFormat.decimal(72.4), "72,4")
    }

    func testLaunchConfigParsing() {
        XCTAssertEqual(LaunchConfig.parse([]).screen, .home)
        XCTAssertEqual(LaunchConfig.parse(["-uiScreen", "pressureSheet"]).screen, .pressureSheet)
        XCTAssertEqual(LaunchConfig.parse(["-uiScreen", "unknown"]).screen, .home)
        XCTAssertEqual(LaunchConfig.parse(["-uiScreen", "error"]).scenario, .failure)
        XCTAssertEqual(LaunchConfig.parse(["-uiScreen", "pressure"]).initialPath, [.pressure])
    }

    @MainActor
    func testStoreAddsMeasurementToTheFront() async {
        let repository = MockHealthRepository(now: now, delayNanoseconds: 0)
        let store = HealthStore(repository: repository)
        await store.load()
        let added = PressureMeasurement(
            id: "new", date: now.addingTimeInterval(60), systolic: 150, diastolic: 95, pulse: nil, context: nil
        )
        store.add(added)
        XCTAssertEqual(store.data.pressure.first?.id, "new")
        XCTAssertEqual(store.screenState, .content)
    }

    @MainActor
    func testStoreReportsFailure() async {
        let store = HealthStore(repository: MockHealthRepository(scenario: .failure, delayNanoseconds: 0))
        await store.load()
        guard case .error = store.screenState else {
            return XCTFail("Ожидалось состояние error")
        }
    }

    @MainActor
    func testStoreReportsEmpty() async {
        let store = HealthStore(repository: MockHealthRepository(scenario: .empty, delayNanoseconds: 0))
        await store.load()
        XCTAssertEqual(store.screenState, .empty)
    }
}
