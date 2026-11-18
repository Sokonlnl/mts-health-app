import XCTest
@testable import HealthMonitor

final class PressureZoneTests: XCTestCase {
    func testBoundaryBelowElevated() {
        XCTAssertEqual(PressureZone.classify(systolic: 129, diastolic: 84), .normal)
    }

    func testElevatedLowerBoundary() {
        XCTAssertEqual(PressureZone.classify(systolic: 130, diastolic: 85), .elevated)
    }

    func testElevatedUpperBoundary() {
        XCTAssertEqual(PressureZone.classify(systolic: 139, diastolic: 89), .elevated)
    }

    func testHighBoundary() {
        XCTAssertEqual(PressureZone.classify(systolic: 140, diastolic: 90), .high)
    }

    func testSystolicAloneElevated() {
        XCTAssertEqual(PressureZone.classify(systolic: 130, diastolic: 70), .elevated)
    }

    func testDiastolicAloneElevated() {
        XCTAssertEqual(PressureZone.classify(systolic: 120, diastolic: 85), .elevated)
    }

    func testWorstOfTwoSystolicHigh() {
        XCTAssertEqual(PressureZone.classify(systolic: 140, diastolic: 70), .high)
    }

    func testWorstOfTwoDiastolicHigh() {
        XCTAssertEqual(PressureZone.classify(systolic: 120, diastolic: 90), .high)
    }

    func testWorstOfTwoMixedElevatedAndHigh() {
        XCTAssertEqual(PressureZone.classify(systolic: 135, diastolic: 95), .high)
        XCTAssertEqual(PressureZone.classify(systolic: 150, diastolic: 87), .high)
    }

    func testTitles() {
        XCTAssertEqual(PressureZone.normal.title, "Норма")
        XCTAssertEqual(PressureZone.elevated.title, "Повышенное")
        XCTAssertEqual(PressureZone.high.title, "Высокое")
    }

    func testOrdering() {
        XCTAssertLessThan(PressureZone.normal, .elevated)
        XCTAssertLessThan(PressureZone.elevated, .high)
    }

    func testThresholdTextMatchesZoneRules() {
        XCTAssertEqual(PressureZone.normal.thresholdText, "<130 и <85")
        XCTAssertEqual(PressureZone.elevated.thresholdText, "130–139 или 85–89")
        XCTAssertEqual(PressureZone.high.thresholdText, "≥140 или ≥90")
        XCTAssertEqual(ZonePlate.plates(current: .elevated).map(\.isCurrent), [false, true, false])
    }
}
