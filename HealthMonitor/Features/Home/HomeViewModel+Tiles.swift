import CoreGraphics
import Foundation

/// Состояние зоны, плитки, вывод и тексты главного экрана.
extension HomeViewModel {
    var emptyMessage: String { "Добавьте первое измерение давления, и здесь появится сводка за неделю." }

    /// Большая плитка бенто (слева): давление со статусом зоны.
    var pressureTile: MetricCardModel { tile(.pressure) }

    /// Две плитки правой колонки бенто: пульс и вес, без статуса.
    var sideTiles: [MetricCardModel] {
        [.pulse, .weight].map(tile)
    }

    /// Карточки под бенто: широкая тёмная «Пульс» и стеклянная «Глюкоза» (повторов бенто нет).
    var listCards: [MetricCardModel] {
        [card(.pulse), card(.glucose)]
    }

    /// Состояние для цвета свечения: всегда по давлению, нет данных даёт серую палитру.
    var glowState: HealthState { state(for: .pressure) }

    var isLoading: Bool { screenState == .loading }

    /// Вывод («Всё спокойно») показывается только при данных.
    var showsInsight: Bool { screenState == .content }

    /// Верх колонки. С выводом (и в loading, чтобы кадр не прыгал) полная высота, в empty и error компактная.
    var columnTop: CGFloat {
        switch screenState {
        case .loading, .content: return Size.homeColumnTop
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

    /// Плитка бенто из карточки показателя: статус зоны только у давления (без данных «Нет данных»), у остальных нет.
    private func tile(_ kind: MetricKind) -> MetricCardModel {
        let model = card(kind)
        let status: String?
        switch (kind, model.valueText) {
        case (.pressure, .some): status = model.statusText
        case (.pressure, .none): status = AppFormat.noData
        default: status = nil
        }
        return MetricCardModel(
            kind: kind, valueText: model.valueText, unit: model.unit, statusText: status,
            tone: kind == .pressure ? model.tone : .neutral, series: []
        )
    }
}
