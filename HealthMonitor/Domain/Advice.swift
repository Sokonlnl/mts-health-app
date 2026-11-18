import Foundation

/// Справочный совет по самочувствию (блок «Советы от ГигаЧата»). Не диагноз и не назначение.
/// `zones`: для каких зон давления совет подходит; пусто: для любой.
struct Advice: Identifiable, Equatable {
    let id: String
    let title: String
    let text: String
    var zones: Set<PressureZone> = []
}

/// Выбор совета по зоне последнего измерения давления.
enum AdviceSelector {
    /// Первый совет, подходящий зоне; без подходящего первый универсальный; иначе первый в списке.
    /// Без данных о давлении (`zone == nil`) берётся универсальный совет.
    static func pick(from items: [Advice], zone: PressureZone?) -> Advice? {
        ordered(items, zone: zone).first
    }

    /// Порядок колоды до смахиваний: сначала советы для зоны, затем универсальные, затем остальные.
    static func ordered(_ items: [Advice], zone: PressureZone?) -> [Advice] {
        let matching = zone.map { zone in items.filter { $0.zones.contains(zone) } } ?? []
        let universal = items.filter { $0.zones.isEmpty }
        let rest = items.filter { item in !matching.contains(item) && !universal.contains(item) }
        return matching + universal + rest
    }

    /// Оговорка при повышенном и высоком давлении (медицинская осторожность), для высокого с советом повторить измерение в покое.
    static func disclaimer(for zone: PressureZone?) -> String? {
        switch zone {
        case .elevated: return HomeText.adviceDisclaimerElevated
        case .high: return HomeText.adviceDisclaimerHigh
        case .normal, nil: return nil
        }
    }
}
