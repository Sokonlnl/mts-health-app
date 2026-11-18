import XCTest
@testable import HealthMonitor

final class HeartbeatRhythmTests: XCTestCase {
    func testPeriodIsSixtyOverPulse() {
        XCTAssertEqual(HeartbeatRhythm(pulse: 68).period, 60.0 / 68.0, accuracy: 0.0001)
        XCTAssertEqual(HeartbeatRhythm(pulse: nil).period, 1, accuracy: 0.0001)
    }

    func testPulseIsClamped() {
        XCTAssertEqual(HeartbeatRhythm(pulse: 5).period, 2, accuracy: 0.0001)
        XCTAssertEqual(HeartbeatRhythm(pulse: 900).period, 60.0 / 220.0, accuracy: 0.0001)
    }

    func testLubDubShapeWithPause() {
        let rhythm = HeartbeatRhythm(pulse: 60)
        let lub = rhythm.pulse(at: 0.08)
        let dub = rhythm.pulse(at: 0.30)
        let between = rhythm.pulse(at: 0.19)
        let pause = rhythm.pulse(at: 0.8)
        XCTAssertGreaterThan(lub, 0.9)
        XCTAssertGreaterThan(dub, 0.5)
        XCTAssertLessThan(dub, lub, "Второй удар слабее первого")
        XCTAssertLessThan(between, 0.3, "Между ударами спад")
        XCTAssertLessThan(pause, 0.01, "Пауза")
    }

    func testScaleIsOneInPauseAndGrowsOnBeat() {
        let rhythm = HeartbeatRhythm(pulse: 60)
        XCTAssertEqual(rhythm.scale(at: 0.8, amplitude: 0.12), 1, accuracy: 0.01)
        XCTAssertGreaterThan(rhythm.scale(at: 0.08, amplitude: 0.12), 1.1)
    }
}
