import Foundation

/// Период просмотра на экране давления.
enum PressurePeriod: CaseIterable {
    case day
    case week
    case month
    case sixMonths

    var title: String {
        switch self {
        case .day: return "День"
        case .week: return "Неделя"
        case .month: return "Месяц"
        case .sixMonths: return "6 мес"
        }
    }

    /// Длина окна в сутках.
    var days: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        case .sixMonths: return 183
        }
    }

    /// Формат подписей оси времени на графике.
    var axisFormat: Date.FormatStyle {
        switch self {
        case .day: return .dateTime.hour().locale(AppFormat.locale)
        case .week: return .dateTime.weekday(.abbreviated).locale(AppFormat.locale)
        case .month: return .dateTime.day().month(.abbreviated).locale(AppFormat.locale)
        case .sixMonths: return .dateTime.month(.abbreviated).locale(AppFormat.locale)
        }
    }

    func startDate(now: Date) -> Date {
        now.addingTimeInterval(-Double(days) * 86_400)
    }
}

/// Сводка за период: последнее, диапазон, среднее.
struct PressureSummary: Equatable {
    let latest: PressureMeasurement?
    let count: Int
    let systolicRange: ClosedRange<Int>?
    let diastolicRange: ClosedRange<Int>?
    let averageSystolic: Int?
    let averageDiastolic: Int?
}

enum PressureAggregator {
    /// Измерения внутри окна периода [начало периода, now], по возрастанию даты.
    /// Записи с датой позже `now` (сбитые часы, ошибочный ввод) в период не попадают.
    static func measurements(_ all: [PressureMeasurement], in period: PressurePeriod, now: Date) -> [PressureMeasurement] {
        let start = period.startDate(now: now)
        return all.filter { $0.date >= start && $0.date <= now }.sorted { $0.date < $1.date }
    }

    static func summary(_ all: [PressureMeasurement], period: PressurePeriod, now: Date) -> PressureSummary {
        let items = measurements(all, in: period, now: now)
        guard let latest = items.last else {
            return PressureSummary(
                latest: nil,
                count: 0,
                systolicRange: nil,
                diastolicRange: nil,
                averageSystolic: nil,
                averageDiastolic: nil
            )
        }
        let systolics = items.map(\.systolic)
        let diastolics = items.map(\.diastolic)
        return PressureSummary(
            latest: latest,
            count: items.count,
            systolicRange: range(of: systolics),
            diastolicRange: range(of: diastolics),
            averageSystolic: average(of: systolics),
            averageDiastolic: average(of: diastolics)
        )
    }

    private static func range(of values: [Int]) -> ClosedRange<Int>? {
        guard let low = values.min(), let high = values.max() else { return nil }
        return low...high
    }

    private static func average(of values: [Int]) -> Int? {
        guard !values.isEmpty else { return nil }
        let sum = values.reduce(0, +)
        return Int((Double(sum) / Double(values.count)).rounded())
    }
}
