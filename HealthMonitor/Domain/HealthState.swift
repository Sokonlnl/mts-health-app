import Foundation

/// Состояние показателя для визуала: определяет палитру формы и цвет статуса.
enum HealthState: Hashable {
    case normal
    case elevated
    case high
    /// Показатель со значением, но без зон (пульс, вес, глюкоза): нейтральная палитра.
    case neutral
    case noData

    init(zone: PressureZone) {
        switch zone {
        case .normal: self = .normal
        case .elevated: self = .elevated
        case .high: self = .high
        }
    }

    /// Тон статуса для пилюли.
    var tone: StatusTone {
        switch self {
        case .normal: return .positive
        case .elevated: return .caution
        case .high: return .critical
        case .neutral, .noData: return .neutral
        }
    }
}
