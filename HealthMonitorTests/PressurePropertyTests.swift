import XCTest
@testable import HealthMonitor

/// Property-тесты: инварианты, которые не должны ломаться ни на каких входах.
/// Тысячи случайных значений из генератора с фиксированным seed: прогон воспроизводим,
/// а пограничные случаи не зависят от того, о чём подумал автор кода.
final class PressurePropertyTests: XCTestCase {
    private let iterations = 10_000

    /// SplitMix64: простой детерминированный генератор, seed фиксирован.
    private struct SeededGenerator: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }
    }

    private var rng = SeededGenerator(state: 20_261_117)

    /// Наивный, заведомо правильный оракул по правилам из CLAUDE.md. Нарочно не использует `PressureZone`:
    /// пороги дублируются, чтобы тест ловил ошибку в самих порогах.
    /// Норма (<130 и <85), Повышенное (130–139 или 85–89), Высокое (≥140 или ≥90).
    private func oracle(_ s: Int, _ d: Int) -> PressureZone {
        if s >= 140 || d >= 90 { return .high }
        if s >= 130 || d >= 85 { return .elevated }
        return .normal
    }

    // MARK: - Зоны

    func testClassifyMatchesNaiveOracle() {
        for _ in 0..<iterations {
            let s = Int.random(in: 50...260, using: &rng)
            let d = Int.random(in: 30...160, using: &rng)
            XCTAssertEqual(PressureZone.classify(systolic: s, diastolic: d), oracle(s, d), "\(s)/\(d)")
        }
    }

    func testClassifyIsWorstOfTwoComponents() {
        for _ in 0..<iterations {
            let s = Int.random(in: 50...260, using: &rng)
            let d = Int.random(in: 30...160, using: &rng)
            let expected = max(PressureZone.zone(systolic: s), PressureZone.zone(diastolic: d))
            XCTAssertEqual(PressureZone.classify(systolic: s, diastolic: d), expected, "\(s)/\(d)")
        }
    }

    func testZoneIsMonotonicInBothValues() {
        for _ in 0..<iterations {
            let s = Int.random(in: 50...250, using: &rng)
            let d = Int.random(in: 30...150, using: &rng)
            let ds = Int.random(in: 0...10, using: &rng)
            let dd = Int.random(in: 0...10, using: &rng)
            let base = PressureZone.classify(systolic: s, diastolic: d)
            XCTAssertGreaterThanOrEqual(PressureZone.classify(systolic: s + ds, diastolic: d), base, "\(s)+\(ds)/\(d)")
            XCTAssertGreaterThanOrEqual(PressureZone.classify(systolic: s, diastolic: d + dd), base, "\(s)/\(d)+\(dd)")
        }
    }

    // MARK: - Агрегация

    private func randomMeasurements(count: Int) -> [PressureMeasurement] {
        (0..<count).map { index in
            TestData.measurement(
                "m\(index)",
                systolic: Int.random(in: 80...200, using: &rng),
                diastolic: Int.random(in: 40...120, using: &rng),
                // Часть дат в будущем (до 2 суток): агрегатор обязан их отбросить.
                secondsAgo: TimeInterval(Int.random(in: (-2 * 86_400)...(200 * 86_400), using: &rng))
            )
        }
    }

    func testSummaryInvariants() {
        for _ in 0..<500 {
            let all = randomMeasurements(count: Int.random(in: 0...40, using: &rng))
            for period in PressurePeriod.allCases {
                let items = PressureAggregator.measurements(all, in: period, now: TestClock.now)
                let summary = PressureAggregator.summary(all, period: period, now: TestClock.now)

                XCTAssertEqual(summary.count, items.count)
                XCTAssertTrue(zip(items, items.dropFirst()).allSatisfy { $0.date <= $1.date }, "порядок по возрастанию даты")
                XCTAssertTrue(items.allSatisfy { $0.date <= TestClock.now }, "нет измерений из будущего")

                guard let range = summary.systolicRange, let avg = summary.averageSystolic,
                      let dRange = summary.diastolicRange, let dAvg = summary.averageDiastolic else {
                    XCTAssertTrue(items.isEmpty, "пустая сводка только при пустом периоде")
                    continue
                }
                XCTAssertTrue(range.contains(avg), "среднее верхнего \(avg) внутри \(range)")
                XCTAssertTrue(dRange.contains(dAvg), "среднее нижнего \(dAvg) внутри \(dRange)")
                XCTAssertEqual(summary.latest?.date, items.last?.date, "последнее = самое новое в периоде")
            }
        }
    }

    func testSummaryDoesNotDependOnInputOrder() {
        for _ in 0..<500 {
            let all = randomMeasurements(count: Int.random(in: 1...30, using: &rng))
            let shuffled = all.shuffled(using: &rng)
            for period in PressurePeriod.allCases {
                let a = PressureAggregator.summary(all, period: period, now: TestClock.now)
                let b = PressureAggregator.summary(shuffled, period: period, now: TestClock.now)
                XCTAssertEqual(a.count, b.count)
                XCTAssertEqual(a.systolicRange, b.systolicRange)
                XCTAssertEqual(a.averageSystolic, b.averageSystolic)
                XCTAssertEqual(a.averageDiastolic, b.averageDiastolic)
                XCTAssertEqual(a.latest?.date, b.latest?.date)
            }
        }
    }

    func testLongerPeriodContainsShorter() {
        let ordered: [PressurePeriod] = [.day, .week, .month, .sixMonths]
        for _ in 0..<500 {
            let all = randomMeasurements(count: Int.random(in: 0...40, using: &rng))
            for (short, long) in zip(ordered, ordered.dropFirst()) {
                let shortIDs = Set(PressureAggregator.measurements(all, in: short, now: TestClock.now).map(\.id))
                let longIDs = Set(PressureAggregator.measurements(all, in: long, now: TestClock.now).map(\.id))
                XCTAssertTrue(shortIDs.isSubset(of: longIDs), "\(short) ⊆ \(long)")
            }
        }
    }
}
