import XCTest
@testable import HealthMonitor

final class HeartbeatRhythmTests: XCTestCase {
    func testPeriodIsThreeTimesSixtyOverPulseWithinBounds() {
        XCTAssertEqual(HeartbeatRhythm(pulse: 68).period, 180.0 / 68.0, accuracy: 0.0001)
        XCTAssertEqual(HeartbeatRhythm(pulse: nil).period, 3, accuracy: 0.0001)
    }

    func testPeriodIsClamped() {
        XCTAssertEqual(HeartbeatRhythm(pulse: 5).period, 3.5, accuracy: 0.0001)
        XCTAssertEqual(HeartbeatRhythm(pulse: 900).period, 2.5, accuracy: 0.0001)
    }

    func testShapeIsSmoothSingleSwell() {
        let rhythm = HeartbeatRhythm(pulse: 60)
        XCTAssertEqual(rhythm.pulse(at: 0), 0, accuracy: 0.0001)
        XCTAssertEqual(rhythm.pulse(at: 0.5), 1, accuracy: 0.0001)
        XCTAssertEqual(rhythm.pulse(at: 1), 0, accuracy: 0.0001)
        var previous = rhythm.pulse(at: 0)
        for step in 1...50 {
            let value = rhythm.pulse(at: Double(step) / 100)
            XCTAssertGreaterThanOrEqual(value, previous, "До пика только рост, без двойного толчка")
            XCTAssertLessThan(value - previous, 0.1, "Без резких скачков")
            previous = value
        }
    }

    func testScaleStaysWithinAmplitude() {
        let rhythm = HeartbeatRhythm(pulse: 60)
        XCTAssertEqual(rhythm.scale(at: 0, amplitude: 0.06), 1, accuracy: 0.0001)
        XCTAssertEqual(rhythm.scale(at: 1.5, amplitude: 0.06), 1.06, accuracy: 0.0001)
    }
}
