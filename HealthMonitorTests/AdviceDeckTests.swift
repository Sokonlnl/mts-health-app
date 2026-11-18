import XCTest
@testable import HealthMonitor

final class AdviceDeckTests: XCTestCase {
    func testDismissRemovesCardsFromTheTop() {
        var deck = AdviceDeck()
        XCTAssertEqual(deck.remaining([1, 2, 3]), [1, 2, 3])
        deck.dismissTop(count: 3)
        XCTAssertEqual(deck.remaining([1, 2, 3]), [2, 3], "Смахнутая карточка не возвращается")
        XCTAssertEqual(deck.position(count: 3), 2)
        deck.dismissTop(count: 3)
        XCTAssertEqual(deck.remaining([1, 2, 3]), [3])
        XCTAssertFalse(deck.isExhausted(count: 3))
    }

    func testDeckIsEmptyAfterAllDismissedAndStaysSo() {
        var deck = AdviceDeck()
        for _ in 0..<3 { deck.dismissTop(count: 3) }
        XCTAssertEqual(deck.remaining([1, 2, 3]), [])
        XCTAssertTrue(deck.isExhausted(count: 3))
        deck.dismissTop(count: 3)
        XCTAssertEqual(deck.remaining([1, 2, 3]), [], "Лишнее смахивание ничего не ломает")
        XCTAssertEqual(deck.position(count: 3), 3)
    }

    func testRefreshRebuildsDeckStartingWithNextAdvice() {
        var deck = AdviceDeck()
        for _ in 0..<3 { deck.dismissTop(count: 3) }
        deck.refresh(count: 3)
        XCTAssertFalse(deck.isExhausted(count: 3))
        XCTAssertEqual(deck.remaining([1, 2, 3]), [2, 3, 1], "После обновления колода начинается с другого совета")
        XCTAssertEqual(deck.remaining([1, 2, 3]).count, 3)
    }

    func testEmptyListHasNoDeck() {
        var deck = AdviceDeck()
        deck.dismissTop(count: 0)
        deck.refresh(count: 0)
        XCTAssertEqual(deck, AdviceDeck())
        XCTAssertEqual(deck.remaining([Int]()), [])
        XCTAssertFalse(deck.isExhausted(count: 0))
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
