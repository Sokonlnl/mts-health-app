import Foundation

/// Порядок колоды советов: верхняя карточка и очередь за ней. Смахивание влево отправляет верхнюю в конец колоды
/// (`next`), вправо возвращает последнюю наверх (`previous`). Чистая логика без UI, проверяется тестами.
struct AdviceDeck: Equatable {
    /// На сколько позиций колода сдвинута относительно исходного порядка.
    private(set) var offset = 0

    mutating func next(count: Int) {
        guard count > 1 else { return }
        offset = (offset + 1) % count
    }

    mutating func previous(count: Int) {
        guard count > 1 else { return }
        offset = (offset - 1 + count) % count
    }

    /// Элементы в текущем порядке колоды: первый на вершине.
    func ordered<Item>(_ items: [Item]) -> [Item] {
        guard !items.isEmpty else { return [] }
        let shift = ((offset % items.count) + items.count) % items.count
        return Array(items[shift...] + items[..<shift])
    }

    /// Номер верхней карточки в исходном порядке, с единицы.
    func position(count: Int) -> Int {
        count > 0 ? offset % count + 1 : 0
    }
}
