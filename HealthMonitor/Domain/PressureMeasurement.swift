import Foundation

/// Контекст измерения (чипы в шторке).
enum MeasurementContext: String, CaseIterable, Identifiable {
    case morning
    case evening
    case afterExercise

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: return "Утро"
        case .evening: return "Вечер"
        case .afterExercise: return "После нагрузки"
        }
    }

    /// Контекст по часу измерения (по календарю приложения): утро 5–10, вечер 17–22, иначе нет (день и ночь).
    /// Моки берут контекст отсюда, чтобы подпись не расходилась со временем.
    static func matching(_ date: Date) -> MeasurementContext? {
        let hour = AppCalendar.calendar.component(.hour, from: date)
        switch hour {
        case 5..<11: return .morning
        case 17..<23: return .evening
        default: return nil
        }
    }
}

/// Одно измерение артериального давления.
struct PressureMeasurement: Identifiable, Equatable {
    let id: String
    let date: Date
    let systolic: Int
    let diastolic: Int
    let pulse: Int?
    let context: MeasurementContext?

    /// Зона по общей логике из `PressureZone`.
    var zone: PressureZone {
        PressureZone.classify(systolic: systolic, diastolic: diastolic)
    }
}

/// Вид показателя на главном экране.
enum MetricKind: String, CaseIterable, Identifiable {
    case pressure
    case pulse
    case weight
    case glucose

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pressure: return "Давление"
        case .pulse: return "Пульс"
        case .weight: return "Вес"
        case .glucose: return "Глюкоза"
        }
    }
}

/// Тон статуса. Сопоставляется с цветами в DesignSystem.
enum StatusTone: Equatable {
    case positive
    case caution
    case critical
    case neutral
}

/// Состояние экрана.
enum ScreenState: Equatable {
    case loading
    case empty
    case error(String)
    case content
}

/// Последнее показание простого показателя (пульс, вес, глюкоза).
struct MetricReading: Equatable {
    let latest: Double?

    static let empty = MetricReading(latest: nil)
}

/// Все данные приложения от одного источника.
struct HealthData: Equatable {
    /// Измерения давления, новые первыми.
    var pressure: [PressureMeasurement]
    var pulse: MetricReading
    var weight: MetricReading
    var glucose: MetricReading
    /// Советы для блока на главном экране (не влияют на «пустое» состояние).
    var advice: [Advice] = []

    static let empty = HealthData(pressure: [], pulse: .empty, weight: .empty, glucose: .empty)

    var isEmpty: Bool {
        pressure.isEmpty && pulse.latest == nil && weight.latest == nil && glucose.latest == nil
    }
}
