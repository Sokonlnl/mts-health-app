import Foundation

/// Состояние колоды советов: сколько карточек смахнули и с какой карточки начинается колода. Смахнутая карточка не
/// возвращается; когда смахнули все, колода пуста до обновления (`refresh`). Чистая логика без UI, проверяется тестами.
struct AdviceDeck: Equatable {
    /// Сколько карточек смахнули с верха колоды.
    private(set) var dismissed = 0
    /// Сдвиг начала колоды: после обновления колода начинается с другого совета.
    private(set) var start = 0

    /// Смахивает верхнюю карточку. Когда смахнуты все, ничего не меняется.
    mutating func dismissTop(count: Int) {
        guard dismissed < count else { return }
        dismissed += 1
    }

    /// «Получить новые советы»: колода собирается заново и начинается со следующего совета.
    mutating func refresh(count: Int) {
        guard count > 0 else { return }
        dismissed = 0
        start = (start + 1) % count
    }

    /// Оставшиеся элементы в порядке колоды: первый на вершине.
    func remaining<Item>(_ items: [Item]) -> [Item] {
        guard !items.isEmpty else { return [] }
        let shift = start % items.count
        let rotated = Array(items[shift...] + items[..<shift])
        return Array(rotated.dropFirst(min(dismissed, rotated.count)))
    }

    /// Смахнуты все карточки (при пустом списке колоды нет).
    func isExhausted(count: Int) -> Bool {
        count > 0 && dismissed >= count
    }

    /// Номер верхней карточки среди всех, с единицы (для VoiceOver).
    func position(count: Int) -> Int {
        count > 0 ? min(dismissed, count - 1) + 1 : 0
    }
}
