import Foundation

/// Ритм сердцебиения для декоративного сердца в карточке давления: двойной удар («lub-dub») и пауза.
/// Период = 60 / пульс. Без пульса 60 уд/мин. Чистая функция фазы, детерминированная и проверяемая тестами.
struct HeartbeatRhythm: Equatable {
    static let defaultBPM = 60
    static let allowedBPM = 30...220
    /// Положения ударов в цикле (доли периода) и ширина каждого; второй удар слабее.
    static let lubPhase = 0.08
    static let dubPhase = 0.30
    static let beatWidth = 0.05
    static let dubStrength = 0.7

    let bpm: Int

    /// `pulse == nil`: 60 уд/мин. Значение прижимается к 30...220.
    init(pulse: Int?) {
        let value = pulse ?? Self.defaultBPM
        bpm = min(Self.allowedBPM.upperBound, max(Self.allowedBPM.lowerBound, value))
    }

    /// Длительность одного цикла (двойной удар и пауза), секунды.
    var period: TimeInterval { 60 / Double(bpm) }

    /// Прибавка к масштабу 0...1 в фазе цикла 0...1: два колокола (удар и более слабый второй), затем пауза.
    func pulse(at phase: Double) -> Double {
        let wrapped = phase - phase.rounded(.down)
        return bump(wrapped, center: Self.lubPhase) + Self.dubStrength * bump(wrapped, center: Self.dubPhase)
    }

    /// Масштаб сердца: 1 + `amplitude` * прибавка.
    func scale(at time: TimeInterval, amplitude: Double) -> Double {
        1 + amplitude * pulse(at: time / period)
    }

    private func bump(_ phase: Double, center: Double) -> Double {
        let distance = (phase - center) / Self.beatWidth
        return exp(-distance * distance)
    }
}
