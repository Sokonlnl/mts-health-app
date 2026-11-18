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

    func testMockHasWeightGlucoseAndAdvice() {
        let data = MockHealthData.make(now: now)
        XCTAssertEqual(data.glucose.latest, 5.4)
        XCTAssertNotNil(data.pulse.latest)
        XCTAssertNotNil(data.weight.latest)
        XCTAssertFalse(data.advice.isEmpty)
        XCTAssertFalse(data.isEmpty)
        XCTAssertTrue(HealthData.empty.isEmpty)
        XCTAssertTrue(HealthData.empty.advice.isEmpty)
    }

    func testMockAdviceIsReferenceWithoutDiagnoses() {
        let ids = Set(MockHealthData.advice.map(\.id))
        XCTAssertEqual(ids.count, MockHealthData.advice.count, "Идентификаторы советов уникальны")
        for advice in MockHealthData.advice {
            let text = (advice.title + " " + advice.text).lowercased()
            XCTAssertFalse(text.contains("диагноз"), advice.id)
            XCTAssertFalse(text.contains("лечени"), advice.id)
        }
    }

    func testGaugeScalePositionClampsToRange() {
        let scale = GaugeScale(range: 50...100)
        XCTAssertEqual(scale.position(of: 50), 0, accuracy: 0.0001)
        XCTAssertEqual(scale.position(of: 75), 0.5, accuracy: 0.0001)
        XCTAssertEqual(scale.position(of: 100), 1, accuracy: 0.0001)
        XCTAssertEqual(scale.position(of: 20), 0, accuracy: 0.0001)
        XCTAssertEqual(scale.position(of: 140), 1, accuracy: 0.0001)
        XCTAssertEqual(GaugeScale.glucose.position(of: 5.4), 0.4, accuracy: 0.0001)
        XCTAssertEqual(GaugeScale(range: 5...5).position(of: 5), 0, accuracy: 0.0001, "Пустой диапазон не делит на ноль")
    }

    func testWeekStatsOnEmptyData() {
        let stats = WeekOverview.stats(measurements: [], now: now)
        XCTAssertEqual(stats, WeekStats(normalDays: 0, measuredDays: 0))
    }

    func testInsightVariants() {
        let calm = WeekInsight.make(stats: WeekStats(normalDays: 6, measuredDays: 7)).details
        let mixed = WeekInsight.make(stats: WeekStats(normalDays: 2, measuredDays: 7)).details
        let empty = WeekInsight.make(stats: WeekStats(normalDays: 0, measuredDays: 0)).details
        XCTAssertTrue(calm.contains("6 из 7"))
        XCTAssertTrue(mixed.contains("обсудите их с врачом"))
        XCTAssertTrue(empty.contains("Добавьте первое измерение"))
        XCTAssertNotEqual(calm, mixed)
    }

    func testFormatting() {
        XCTAssertEqual(AppFormat.pressureValue(122, 79), "122/79")
        XCTAssertEqual(AppFormat.range(118...136), "118–136")
        XCTAssertEqual(AppFormat.range(120...120), "120")
        XCTAssertEqual(AppFormat.range(nil), "–")
        XCTAssertEqual(AppFormat.decimal(72.4), "72,4")
        XCTAssertEqual(AppFormat.unitCaption("ммоль/л", status: "Измерений пока нет"), "ммоль/л · измерений пока нет")
        XCTAssertEqual(AppFormat.pressureUnit(pulse: nil), AppUnit.pressure)
        XCTAssertEqual(AppFormat.pressureUnit(pulse: 68), "мм рт. ст. · пульс 68")
        XCTAssertEqual(AppFormat.metricAccessibility(title: "Вес", value: "72,4", unit: "кг", status: nil), "Вес 72,4 кг")
        XCTAssertEqual(AppFormat.metricAccessibility(title: "Вес", value: nil, unit: "кг", status: nil), "Вес: нет данных")
    }

    func testMockContextMatchesHourOfMeasurement() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let items = MockHealthData.pressure(now: now)
        XCTAssertFalse(items.isEmpty)
        for item in items {
            XCTAssertEqual(item.context, MeasurementContext.matching(item.date), item.id)
        }
        let calendar = AppCalendar.calendar
        func date(hour: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) ?? now
        }
        XCTAssertNil(MeasurementContext.matching(date(hour: 4)))
        XCTAssertEqual(MeasurementContext.matching(date(hour: 5)), .morning)
        XCTAssertEqual(MeasurementContext.matching(date(hour: 10)), .morning)
        XCTAssertNil(MeasurementContext.matching(date(hour: 11)))
        XCTAssertNil(MeasurementContext.matching(date(hour: 16)))
        XCTAssertEqual(MeasurementContext.matching(date(hour: 17)), .evening)
        XCTAssertEqual(MeasurementContext.matching(date(hour: 22)), .evening)
        XCTAssertNil(MeasurementContext.matching(date(hour: 23)))
    }

    func testLaunchConfigParsing() {
        XCTAssertEqual(LaunchConfig.parse([]).screen, .home)
        XCTAssertEqual(LaunchConfig.parse(["-uiScreen", "unknown"]).screen, .home)
        XCTAssertEqual(LaunchConfig.parse(["-uiScreen", "error"]).scenario, .failure)
        XCTAssertEqual(LaunchConfig.parse(["-uiScreen", "pressure"]).initialPath, [.pressure])
        XCTAssertFalse(LaunchConfig.parse([]).disablesIntro)
        XCTAssertTrue(LaunchConfig.parse([LaunchConfig.disableIntroArgument]).disablesIntro)
        XCTAssertTrue(LaunchConfig.parse(["-uiScreen", "pressure", LaunchConfig.disableIntroArgument]).disablesIntro)
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
