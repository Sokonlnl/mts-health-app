import CoreGraphics
import Foundation

/// Плитка показателя в ряду под свечением. Нет значения: `valueText == nil` (во View прочерк).
struct TileModel: Identifiable, Equatable {
    let kind: MetricKind
    let valueText: String?
    let unit: String
    /// Статус зоны текстом (только у давления). Цвет задаёт `tone`, но смысл несёт текст.
    let statusText: String?
    let tone: StatusTone

    var id: String { kind.id }
    var label: String { kind.title }
}

/// Состояние зоны, плитки, вывод и тексты главного экрана.
extension HomeViewModel {
    var emptyMessage: String { "Добавьте первое измерение давления, и здесь появится сводка за неделю." }

    var tiles: [TileModel] {
        [.pressure, .pulse, .weight].map(tile)
    }

    /// Состояние для цвета свечения: всегда по давлению, нет данных даёт серую палитру.
    var glowState: HealthState { state(for: .pressure) }

    var isLoading: Bool { screenState == .loading }

    /// Вывод («Всё спокойно») показывается только при данных.
    var showsInsight: Bool { screenState == .content }

    /// Верх ряда плиток. С выводом (и в loading, чтобы кадр не прыгал) полная высота, в empty и error компактная.
    var tilesTop: CGFloat {
        switch screenState {
        case .loading, .content: return Size.homeTilesTop
        case .empty, .error: return Size.homeCompactTop
        }
    }

    func state(for kind: MetricKind) -> HealthState {
        let data = store.data
        switch kind {
        case .pressure:
            return data.pressure.first.map { HealthState(zone: $0.zone) } ?? .noData
        case .pulse:
            return data.pulse.latest == nil ? .noData : .neutral
        case .weight:
            return data.weight.latest == nil ? .noData : .neutral
        case .glucose:
            return data.glucose.latest == nil ? .noData : .neutral
        }
    }

    /// Заголовок-вывод по недельной статистике давления.
    var headline: HeadlineModel {
        let current = insight
        return HeadlineModel(title: current.title, summary: current.summary, details: current.details)
    }

    private func tile(_ kind: MetricKind) -> TileModel {
        let model = card(kind)
        guard kind == .pressure else {
            return TileModel(kind: kind, valueText: model.valueText, unit: model.unit, statusText: nil, tone: .neutral)
        }
        guard model.valueText != nil else {
            return TileModel(kind: kind, valueText: nil, unit: model.unit, statusText: AppFormat.noData, tone: .neutral)
        }
        return TileModel(kind: kind, valueText: model.valueText, unit: model.unit, statusText: model.statusText, tone: model.tone)
    }
}
