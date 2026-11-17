import Foundation

/// Шкала дуги зон на главном экране: доли дуги по зонам и положение маркера.
/// Только отображение, границы зон берутся из `PressureZone`.
enum PressureScale {
    /// Опорные значения шкалы одного из давлений.
    private struct Thresholds {
        let low: Double
        let elevated: Double
        let high: Double
        let top: Double
    }

    private static let systolic = Thresholds(low: 90, elevated: 130, high: 140, top: 170)
    private static let diastolic = Thresholds(low: 50, elevated: 85, high: 90, top: 110)

    /// Доля дуги, которую занимает зона.
    static func fraction(for zone: PressureZone) -> Double {
        switch zone {
        case .normal: return 0.5
        case .elevated: return 0.125
        case .high: return 0.375
        }
    }

    /// Положение маркера на дуге 0...1: худшее из положений верхнего и нижнего давления.
    static func progress(systolic top: Int, diastolic bottom: Int) -> Double {
        max(position(top, on: systolic), position(bottom, on: diastolic))
    }

    private static func position(_ value: Int, on scale: Thresholds) -> Double {
        let current = Double(value)
        let normal = fraction(for: .normal)
        let elevated = fraction(for: .elevated)
        let high = fraction(for: .high)
        if current < scale.elevated {
            return normal * unit((current - scale.low) / (scale.elevated - scale.low))
        }
        if current < scale.high {
            return normal + elevated * unit((current - scale.elevated) / (scale.high - scale.elevated))
        }
        return normal + elevated + high * unit((current - scale.high) / (scale.top - scale.high))
    }

    private static func unit(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}

extension PressureZone {
    /// Границы зоны для плашек «Почему такой статус».
    var thresholdText: String {
        switch self {
        case .normal: return "<130 и <85"
        case .elevated: return "130–139 или 85–89"
        case .high: return "≥140 или ≥90"
        }
    }
}
