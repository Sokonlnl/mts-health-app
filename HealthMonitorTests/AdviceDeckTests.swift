import XCTest
@testable import HealthMonitor

final class AdviceDeckTests: XCTestCase {
    func testOrderedStartsWithTopAndCycles() {
        var deck = AdviceDeck()
        XCTAssertEqual(deck.ordered([1, 2, 3]), [1, 2, 3])
        deck.next(count: 3)
        XCTAssertEqual(deck.ordered([1, 2, 3]), [2, 3, 1])
        deck.next(count: 3)
        deck.next(count: 3)
        XCTAssertEqual(deck.ordered([1, 2, 3]), [1, 2, 3], "Полный круг возвращает порядок")
        deck.previous(count: 3)
        XCTAssertEqual(deck.ordered([1, 2, 3]), [3, 1, 2])
        XCTAssertEqual(deck.position(count: 3), 3)
    }

    func testSingleOrEmptyDeckDoesNotMove() {
        var deck = AdviceDeck()
        deck.next(count: 1)
        deck.previous(count: 0)
        XCTAssertEqual(deck, AdviceDeck())
        XCTAssertEqual(deck.ordered([Int]()), [])
        XCTAssertEqual(deck.position(count: 0), 0)
    }

    func testSelectorPutsZoneAdviceFirstThenUniversal() {
        let all = MockHealthData.advice
        let high = AdviceSelector.ordered(all, zone: .high)
        XCTAssertEqual(high.first?.zones.contains(.high), true)
        XCTAssertEqual(high.count, all.count)
        XCTAssertEqual(Set(high.map { $0.id }), Set(all.map { $0.id }))
        XCTAssertEqual(AdviceSelector.pick(from: all, zone: .high)?.id, high.first?.id)
    }
}
