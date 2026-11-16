import Foundation

/// Зона артериального давления. Справочная информация, не диагноз.
/// Порядок кейсов важен: от лучшей зоны к худшей.
enum PressureZone: Int, CaseIterable, Comparable {
    case normal
    case elevated
    case high

    /// Русское название зоны для UI.
    var title: String {
        switch self {
        case .normal: return "Норма"
        case .elevated: return "Повышенное"
        case .high: return "Высокое"
        }
    }

    static func < (lhs: PressureZone, rhs: PressureZone) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Зона по верхнему (систолическому) значению.
    static func zone(systolic: Int) -> PressureZone {
        switch systolic {
        case ..<130: return .normal
        case 130..<140: return .elevated
        default: return .high
        }
    }

    /// Зона по нижнему (диастолическому) значению.
    static func zone(diastolic: Int) -> PressureZone {
        switch diastolic {
        case ..<85: return .normal
        case 85..<90: return .elevated
        default: return .high
        }
    }

    /// Итоговая зона: худшая из двух оценок.
    static func classify(systolic: Int, diastolic: Int) -> PressureZone {
        max(zone(systolic: systolic), zone(diastolic: diastolic))
    }
}
