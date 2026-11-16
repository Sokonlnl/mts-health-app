import XCTest
@testable import HealthMonitor

final class PressureAggregationTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let hour: TimeInterval = 3_600

    private func measurement(
        _ id: String,
        hoursAgo: Double,
        systolic: Int,
        diastolic: Int
    ) -> PressureMeasurement {
        PressureMeasurement(
            id: id,
            date: now.addingTimeInterval(-hoursAgo * hour),
            systolic: systolic,
            diastolic: diastolic,
            pulse: 65,
            context: nil
        )
    }

    func testDayWindowKeepsOnlyLast24Hours() {
        let all = [
            measurement("a", hoursAgo: 1, systolic: 120, diastolic: 80),
            measurement("b", hoursAgo: 23, systolic: 130, diastolic: 85),
            measurement("c", hoursAgo: 25, systolic: 140, diastolic: 90)
        ]
        let items = PressureAggregator.measurements(all, in: .day, now: now)
        XCTAssertEqual(items.map(\.id), ["b", "a"])
    }

    func testWeekSummaryLatestRangeAndAverage() {
        let all = [
            measurement("old", hoursAgo: 48, systolic: 118, diastolic: 74),
            measurement("mid", hoursAgo: 24, systolic: 126, diastolic: 82),
            measurement("new", hoursAgo: 1, systolic: 136, diastolic: 88)
        ]
        let summary = PressureAggregator.summary(all, period: .week, now: now)
        XCTAssertEqual(summary.latest?.id, "new")
        XCTAssertEqual(summary.count, 3)
        XCTAssertEqual(summary.systolicRange, 118...136)
        XCTAssertEqual(summary.diastolicRange, 74...88)
        XCTAssertEqual(summary.averageSystolic, 127)
        XCTAssertEqual(summary.averageDiastolic, 81)
    }

    func testAverageRoundsToNearest() {
        let all = [
            measurement("a", hoursAgo: 2, systolic: 120, diastolic: 80),
            measurement("b", hoursAgo: 1, systolic: 121, diastolic: 81)
        ]
        let summary = PressureAggregator.summary(all, period: .day, now: now)
        XCTAssertEqual(summary.averageSystolic, 121)
        XCTAssertEqual(summary.averageDiastolic, 81)
    }

    func testEmptyPeriodHasNoValues() {
        let all = [measurement("old", hoursAgo: 24 * 40, systolic: 120, diastolic: 80)]
        let summary = PressureAggregator.summary(all, period: .month, now: now)
        XCTAssertNil(summary.latest)
        XCTAssertEqual(summary.count, 0)
        XCTAssertNil(summary.systolicRange)
        XCTAssertNil(summary.averageSystolic)
    }

    func testMonthAndSixMonthWindows() {
        let all = [
            measurement("d20", hoursAgo: 24 * 20, systolic: 120, diastolic: 80),
            measurement("d100", hoursAgo: 24 * 100, systolic: 125, diastolic: 82),
            measurement("d200", hoursAgo: 24 * 200, systolic: 130, diastolic: 85)
        ]
        XCTAssertEqual(PressureAggregator.measurements(all, in: .month, now: now).count, 1)
        XCTAssertEqual(PressureAggregator.measurements(all, in: .sixMonths, now: now).count, 2)
    }

    func testMeasurementsAreSortedAscending() {
        let all = [
            measurement("new", hoursAgo: 1, systolic: 120, diastolic: 80),
            measurement("old", hoursAgo: 5, systolic: 121, diastolic: 81)
        ]
        let items = PressureAggregator.measurements(all, in: .week, now: now)
        XCTAssertEqual(items.map(\.id), ["old", "new"])
    }

    func testAxisFormatPerPeriod() {
        XCTAssertEqual(PressurePeriod.day.axisFormat, .dateTime.hour())
        XCTAssertEqual(PressurePeriod.week.axisFormat, .dateTime.weekday(.abbreviated))
        XCTAssertEqual(PressurePeriod.month.axisFormat, .dateTime.day().month(.abbreviated))
        XCTAssertEqual(PressurePeriod.sixMonths.axisFormat, .dateTime.month(.abbreviated))
    }

    func testPeriodTitles() {
        XCTAssertEqual(PressurePeriod.allCases.map(\.title), ["День", "Неделя", "Месяц", "6 мес"])
    }
}
