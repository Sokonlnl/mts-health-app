import Foundation

/// Положение маркера на мини-шкале показателя (вес, глюкоза): значение в диапазоне шкалы, доля 0...1.
/// Только отображение: шкала не называет норму и не ставит оценок, границы нужны для рисунка маркера.
struct GaugeScale: Equatable {
    let range: ClosedRange<Double>

    /// Положение значения на шкале, значения вне диапазона прижимаются к краям.
    func position(of value: Double) -> Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return min(1, max(0, (value - range.lowerBound) / span))
    }

    static let weight = GaugeScale(range: 50...100)
    static let glucose = GaugeScale(range: 3...9)
}
