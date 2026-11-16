import XCTest
@testable import HealthMonitor

/// Граничные случаи валидации шторки. Дополняет `MeasurementDraftTests`.
final class MeasurementDraftValidationTests: XCTestCase {
    private func draft(_ systolic: String, _ diastolic: String, pulse: String = "") -> MeasurementDraft {
        var value = MeasurementDraft(date: Date(timeIntervalSince1970: 0))
        value.systolicText = systolic
        value.diastolicText = diastolic
        value.pulseText = pulse
        return value
    }

    func testSystolic300IsOutOfRange() {
        let value = draft("300", "80")
        XCTAssertFalse(value.isValid)
        XCTAssertEqual(value.issues, [.systolicOutOfRange])
        XCTAssertNil(value.makeMeasurement(id: "x"))
        XCTAssertNil(value.zone)
    }

    func testSystolicBelowDiastolicIsInvalid() {
        let value = draft("120", "130")
        XCTAssertFalse(value.isValid)
        XCTAssertEqual(value.issues, [.systolicNotAboveDiastolic])
        XCTAssertEqual(value.hint, MeasurementIssue.systolicNotAboveDiastolic.message)
    }

    func testSystolic69IsOutOfRangeAndNotAboveDiastolic() {
        let value = draft("69", "80")
        XCTAssertFalse(value.isValid)
        XCTAssertTrue(value.issues.contains(.systolicOutOfRange))
        XCTAssertTrue(value.issues.contains(.systolicNotAboveDiastolic))
    }

    func testDiastolic150Boundary() {
        let value = draft("250", "150")
        XCTAssertTrue(value.isValid, "250/150 лежит на границах допустимых диапазонов")
        XCTAssertEqual(value.zone, .high)
        XCTAssertFalse(draft("250", "151").isValid)
    }

    func testPulseBoundaries() {
        XCTAssertFalse(draft("120", "80", pulse: "29").isValid)
        XCTAssertTrue(draft("120", "80", pulse: "30").isValid)
        XCTAssertTrue(draft("120", "80", pulse: "220").isValid)
        let tooHigh = draft("120", "80", pulse: "221")
        XCTAssertFalse(tooHigh.isValid)
        XCTAssertEqual(tooHigh.issues, [.pulseOutOfRange])
    }

    func testEmptyFieldsHaveNoIssuesButAreNotValid() {
        let value = draft("", "")
        XCTAssertTrue(value.issues.isEmpty)
        XCTAssertFalse(value.isValid)
        XCTAssertNil(value.hint)
        XCTAssertNil(value.systolic)
        XCTAssertNil(value.diastolic)
    }

    func testOnlyOnePressureFieldIsNotValid() {
        XCTAssertFalse(draft("120", "").isValid)
        XCTAssertFalse(draft("", "80").isValid)
    }

    func testFourthDigitIsRejectedInEveryField() {
        for field in MeasurementField.allCases {
            var value = MeasurementDraft(date: Date(timeIntervalSince1970: 0))
            value.append(digit: 1, to: field)
            value.append(digit: 2, to: field)
            value.append(digit: 3, to: field)
            XCTAssertFalse(value.append(digit: 4, to: field), "Четвёртая цифра не должна давать сигнал перехода")
            XCTAssertEqual(value.text(for: field), "123")
        }
    }

    func testAdvanceSignalOnlyOnThirdDigit() {
        var value = MeasurementDraft(date: Date(timeIntervalSince1970: 0))
        XCTAssertFalse(value.append(digit: 1, to: .diastolic))
        XCTAssertFalse(value.append(digit: 2, to: .diastolic))
        XCTAssertTrue(value.append(digit: 3, to: .diastolic))
    }

    func testInvalidDigitIsIgnored() {
        var value = MeasurementDraft(date: Date(timeIntervalSince1970: 0))
        XCTAssertFalse(value.append(digit: 10, to: .systolic))
        XCTAssertFalse(value.append(digit: -1, to: .systolic))
        XCTAssertEqual(value.systolicText, "")
    }

    func testZoneBoundariesThroughDraft() {
        XCTAssertEqual(draft("129", "84").zone, .normal)
        XCTAssertEqual(draft("130", "85").zone, .elevated)
        XCTAssertEqual(draft("139", "89").zone, .elevated)
        XCTAssertEqual(draft("140", "90").zone, .high)
    }
}
