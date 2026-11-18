import XCTest
@testable import HealthMonitor

final class PressureFormattingTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func measurement(pulse: Int?, context: MeasurementContext?) -> PressureMeasurement {
        PressureMeasurement(id: "m", date: now, systolic: 132, diastolic: 86, pulse: pulse, context: context)
    }

    func testMeasurementTitleWithAndWithoutPulse() {
        XCTAssertEqual(AppFormat.measurementTitle(measurement(pulse: 70, context: nil)), "132/86 · 70")
        XCTAssertEqual(AppFormat.measurementTitle(measurement(pulse: nil, context: nil)), "132/86")
    }

    func testMeasurementSubtitleWithContext() {
        let plain = AppFormat.measurementSubtitle(measurement(pulse: nil, context: nil), now: now)
        let withContext = AppFormat.measurementSubtitle(measurement(pulse: nil, context: .morning), now: now)
        XCTAssertTrue(plain.hasPrefix("Сегодня, "))
        XCTAssertEqual(withContext, "\(plain) · Утро")
    }

    func testAxisThreshold() {
        XCTAssertEqual(AppFormat.axisThreshold(140, upperBound: 140), "140+")
        XCTAssertEqual(AppFormat.axisThreshold(130, upperBound: 139), "130")
    }

    @MainActor
    func testLatestValueTextForEmptyStore() {
        let store = HealthStore(repository: MockHealthRepository(scenario: .empty, delayNanoseconds: 0))
        let viewModel = PressureViewModel(store: store, now: { self.now })
        XCTAssertEqual(viewModel.latestValueText, AppFormat.emptyPressureValue)
        XCTAssertTrue(viewModel.historyRows.isEmpty)
    }
}
