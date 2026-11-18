import Foundation

/// Ритм сердцебиения декоративного сердца в карточке давления: медленное мягкое «дыхание-удар» без резких толчков.
/// Период = 60 / пульс × 3 с, в пределах 2,5...3,5 с (`periodRange`). Без пульса 60 уд/мин (3 с).
/// Чистая функция фазы, детерминированная и проверяемая тестами.
struct HeartbeatRhythm: Equatable {
    static let defaultBPM = 60
    static let allowedBPM = 30...220
    /// Период цикла: 60 / пульс × `periodFactor` секунд, в пределах `periodRange`.
    static let periodFactor: Double = 3
    static let periodRange: ClosedRange<TimeInterval> = 2.5...3.5

    let bpm: Int

    /// `pulse == nil`: 60 уд/мин. Значение прижимается к 30...220.
    init(pulse: Int?) {
        let value = pulse ?? Self.defaultBPM
        bpm = min(Self.allowedBPM.upperBound, max(Self.allowedBPM.lowerBound, value))
    }

    /// Длительность одного цикла, секунды.
    var period: TimeInterval {
        let raw = 60 / Double(bpm) * Self.periodFactor
        return min(Self.periodRange.upperBound, max(Self.periodRange.lowerBound, raw))
    }

    /// Прибавка к масштабу 0...1 в фазе цикла 0...1: плавный подъём в начале цикла и плавный спад (easeInOut), без пауз-рывков.
    func pulse(at phase: Double) -> Double {
        let wrapped = phase - phase.rounded(.down)
        return 0.5 - 0.5 * cos(2 * Double.pi * wrapped)
    }

    /// Масштаб сердца: 1 + `amplitude` * прибавка.
    func scale(at time: TimeInterval, amplitude: Double) -> Double {
        1 + amplitude * pulse(at: time / period)
    }
}
