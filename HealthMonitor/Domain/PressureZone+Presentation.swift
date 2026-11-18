import Foundation

extension PressureZone {
    /// Тон статуса для пилюли.
    var tone: StatusTone {
        switch self {
        case .normal: return .positive
        case .elevated: return .caution
        case .high: return .critical
        }
    }

    /// Пояснение к зоне. Справочная информация, не диагноз.
    var explanation: String {
        switch self {
        case .normal:
            return "Верхнее ниже 130 и нижнее ниже 85 мм рт. ст. Такие значения попадают в зону нормы по справочной шкале."
        case .elevated:
            return "Верхнее 130–139 или нижнее 85–89 мм рт. ст. Стоит понаблюдать за динамикой и отмечать контекст измерений."
        case .high:
            return "Верхнее от 140 или нижнее от 90 мм рт. ст. Если такие значения повторяются, обсудите их с врачом."
        }
    }

    /// Граница зоны для плашки «Почему такой статус» (по CLAUDE.md, правило 6).
    var thresholdText: String {
        switch self {
        case .normal: return "<130 и <85"
        case .elevated: return "130–139 или 85–89"
        case .high: return "≥140 или ≥90"
        }
    }

    static let disclaimer = "Справочная информация, не заменяет консультацию врача."

    /// Диапазон верхнего давления, который зона занимает на графике.
    func systolicBand(within domain: ClosedRange<Int>) -> ClosedRange<Int> {
        let low = min(domain.lowerBound, 130)
        let high = max(domain.upperBound, 140)
        switch self {
        case .normal: return low...130
        case .elevated: return 130...140
        case .high: return 140...high
        }
    }
}
