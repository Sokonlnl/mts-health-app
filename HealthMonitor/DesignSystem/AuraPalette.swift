import SwiftUI

/// Палитра градиента формы Aura: пять цветов и свечение маркера (порядок цветов важен).
struct AuraPalette: Hashable {
    let c0: Color
    let c1: Color
    let c2: Color
    let c3: Color
    let c4: Color
    let markerGlow: Color

    var colors: [Color] { [c0, c1, c2, c3, c4] }

    static let normal = AuraPalette(
        c0: Color(hex: 0x37F2B3), c1: Color(hex: 0x2BC4FF), c2: Color(hex: 0x6E6BFF),
        c3: Color(hex: 0xB58CFF), c4: Color(hex: 0x7DF7D5), markerGlow: Color(hex: 0x37F2B3, opacity: 0.35)
    )
    static let elevated = AuraPalette(
        c0: Color(hex: 0xFFC857), c1: Color(hex: 0xFF8A4C), c2: Color(hex: 0xFF5F7A),
        c3: Color(hex: 0xC46BFF), c4: Color(hex: 0xFFE29A), markerGlow: Color(hex: 0xFFC857, opacity: 0.35)
    )
    static let high = AuraPalette(
        c0: Color(hex: 0xFF4D6A), c1: Color(hex: 0xFF7A45), c2: Color(hex: 0xD43DB0),
        c3: Color(hex: 0x7A4DFF), c4: Color(hex: 0xFF9AA8), markerGlow: Color(hex: 0xFF6B81, opacity: 0.35)
    )
    static let noData = AuraPalette(
        c0: Color(hex: 0x5A6478), c1: Color(hex: 0x39445A), c2: Color(hex: 0x2B3447),
        c3: Color(hex: 0x66718A), c4: Color(hex: 0x444F66), markerGlow: Color(hex: 0x8A93A6, opacity: 0.25)
    )
}

extension HealthState {
    /// Палитра формы для состояния.
    var palette: AuraPalette {
        switch self {
        case .normal: return .normal
        case .elevated: return .elevated
        case .high: return .high
        case .neutral, .noData: return .noData
        }
    }
}
