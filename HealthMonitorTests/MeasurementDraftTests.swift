import XCTest
@testable import HealthMonitor

final class MeasurementDraftTests: XCTestCase {
    private func draft(_ systolic: String, _ diastolic: String, pulse: String = "") -> MeasurementDraft {
        var draft = MeasurementDraft(date: Date(timeIntervalSince1970: 0))
        draft.systolicText = systolic
        draft.diastolicText = diastolic
        draft.pulseText = pulse
        return draft
    }

    func testValidTypicalInput() {
        XCTAssertTrue(draft("120", "80").isValid)
    }

    func testEmptyInputIsInvalid() {
        XCTAssertFalse(draft("", "").isValid)
        XCTAssertFalse(draft("120", "").isValid)
        XCTAssertFalse(draft("", "80").isValid)
    }

    func testSystolicBounds() {
        XCTAssertTrue(draft("70", "40").isValid)
        XCTAssertFalse(draft("69", "40").isValid)
        XCTAssertTrue(draft("250", "100").isValid)
        XCTAssertFalse(draft("251", "100").isValid)
    }

    func testDiastolicBounds() {
        XCTAssertTrue(draft("200", "40").isValid)
        XCTAssertFalse(draft("200", "39").isValid)
        XCTAssertTrue(draft("200", "150").isValid)
        XCTAssertFalse(draft("200", "151").isValid)
    }

    func testSystolicMustBeAboveDiastolic() {
        XCTAssertFalse(draft("90", "90").isValid)
        XCTAssertFalse(draft("80", "90").isValid)
        XCTAssertTrue(draft("91", "90").isValid)
        XCTAssertTrue(draft("80", "90").issues.contains(.systolicNotAboveDiastolic))
    }

    func testPulseIsOptionalButBounded() {
        XCTAssertTrue(draft("120", "80", pulse: "").isValid)
        XCTAssertFalse(draft("120", "80", pulse: "29").isValid)
        XCTAssertTrue(draft("120", "80", pulse: "30").isValid)
        XCTAssertTrue(draft("120", "80", pulse: "220").isValid)
        XCTAssertFalse(draft("120", "80", pulse: "221").isValid)
    }

    func testZoneOnlyForValidInput() {
        XCTAssertEqual(draft("120", "80").zone, .normal)
        XCTAssertEqual(draft("135", "80").zone, .elevated)
        XCTAssertEqual(draft("145", "80").zone, .high)
        XCTAssertNil(draft("60", "40").zone)
    }

    func testHintShowsFirstIssue() {
        XCTAssertNil(draft("120", "80").hint)
        XCTAssertEqual(draft("260", "80").hint, MeasurementIssue.systolicOutOfRange.message)
    }

    func testAppendLimitsToThreeDigitsAndSignalsAdvance() {
        var value = MeasurementDraft(date: Date(timeIntervalSince1970: 0))
        XCTAssertFalse(value.append(digit: 1, to: .systolic))
        XCTAssertFalse(value.append(digit: 2, to: .systolic))
        XCTAssertTrue(value.append(digit: 0, to: .systolic))
        XCTAssertFalse(value.append(digit: 5, to: .systolic))
        XCTAssertEqual(value.systolicText, "120")
    }

    func testLeadingZeroIsIgnored() {
        var value = MeasurementDraft(date: Date(timeIntervalSince1970: 0))
        value.append(digit: 0, to: .pulse)
        XCTAssertEqual(value.pulseText, "")
    }

    func testDeleteLast() {
        var value = draft("120", "80")
        value.deleteLast(from: .systolic)
        XCTAssertEqual(value.systolicText, "12")
        value.deleteLast(from: .pulse)
        XCTAssertEqual(value.pulseText, "")
    }

    func testFieldOrder() {
        XCTAssertEqual(MeasurementField.systolic.next, .diastolic)
        XCTAssertEqual(MeasurementField.diastolic.next, .pulse)
        XCTAssertEqual(MeasurementField.pulse.next, .pulse)
    }

    func testMakeMeasurement() {
        var value = draft("132", "86", pulse: "70")
        value.context = .evening
        let result = value.makeMeasurement(id: "x")
        XCTAssertEqual(result?.systolic, 132)
        XCTAssertEqual(result?.diastolic, 86)
        XCTAssertEqual(result?.pulse, 70)
        XCTAssertEqual(result?.context, .evening)
        XCTAssertEqual(result?.zone, .elevated)
        XCTAssertNil(draft("60", "80").makeMeasurement(id: "y"))
    }
}
