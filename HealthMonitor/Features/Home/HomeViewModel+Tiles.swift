import CoreGraphics
import Foundation

/// Карточки, вывод, совет и вид верхнего блока главного экрана.
extension HomeViewModel {
    var emptyMessage: String { HomeText.emptyMessage }

    /// Большая карточка давления со статусом зоны (без данных «Нет данных»).
    var pressureCard: MetricCardModel {
        guard let latest = store.data.pressure.first else {
            return MetricCardModel(
                kind: .pressure, valueText: nil, unit: AppUnit.pressure, statusText: AppFormat.noData, tone: .neutral,
                gaugePosition: nil
            )
        }
        return MetricCardModel(
            kind: .pressure,
            valueText: AppFormat.pressureValue(latest.systolic, latest.diastolic),
            unit: AppUnit.pressure,
            statusText: latest.zone.title,
            tone: latest.zone.tone,
            gaugePosition: nil,
            rhythm: heartbeat
        )
    }

    var weightCard: MetricCardModel {
        gaugeCard(.weight, reading: store.data.weight, unit: AppUnit.weight, scale: .weight)
    }

    var glucoseCard: MetricCardModel {
        gaugeCard(.glucose, reading: store.data.glucose, unit: AppUnit.glucose, scale: .glucose)
    }

    /// Малые карточки в ряд: вес и глюкоза.
    var smallCards: [MetricCardModel] { [weightCard, glucoseCard] }

    /// Состояние для цвета свечения: по последнему измерению давления, нет данных даёт серую палитру.
    var glowState: HealthState {
        store.data.pressure.first.map { HealthState(zone: $0.zone) } ?? .noData
    }

    /// Вывод: заголовок и пояснение по зоне последнего измерения, подробности по неделе.
    var headline: HeadlineModel {
        let text = HomeText.headline(for: glowState)
        return HeadlineModel(title: text.title, summary: text.summary, details: insight.details)
    }

    /// Ритм сердцебиения по пульсу из данных (без пульса 60 уд/мин).
    var heartbeat: HeartbeatRhythm {
        HeartbeatRhythm(pulse: store.data.pulse.latest.map { Int($0.rounded()) })
    }

    /// Совет для карточки в блоке «Советы от ГигаЧата»: подбирается по зоне последнего измерения, при повышенном и высоком
    /// давлении с оговоркой (справочная информация).
    var adviceCard: AdviceCardModel? {
        let zone = store.data.pressure.first?.zone
        return AdviceSelector.pick(from: store.data.advice, zone: zone).map {
            AdviceCardModel(
                title: $0.title, text: $0.text, author: HomeText.gigachatName, role: HomeText.gigachatRole,
                iconName: "sparkles", disclaimer: AdviceSelector.disclaimer(for: zone)
            )
        }
    }

    var isLoading: Bool { screenState == .loading }

    /// Вывод показывается только при данных.
    var showsInsight: Bool { screenState == .content }

    /// Высота верхнего блока: полная с выводом (и в loading, чтобы кадр не прыгал), в empty и error компактная.
    var heroHeight: CGFloat {
        switch screenState {
        case .loading, .content: return Size.heroHeight
        case .empty, .error: return Size.heroCompactHeight
        }
    }

    private func gaugeCard(_ kind: MetricKind, reading: MetricReading, unit: String, scale: GaugeScale) -> MetricCardModel {
        MetricCardModel(
            kind: kind,
            valueText: reading.latest.map(AppFormat.decimal),
            unit: unit,
            statusText: nil,
            tone: .neutral,
            gaugePosition: reading.latest.map(scale.position(of:))
        )
    }
}
