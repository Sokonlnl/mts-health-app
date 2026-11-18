import SwiftUI

/// Палитра состояния: цвет свечения верхнего блока (`glow`) и свечение маркера на графике давления.
struct AuraPalette: Hashable {
    let glow: Color
    let markerGlow: Color
    /// Картинка героя `HeroGlow` зелёная: у нормы остаётся как есть, у остальных зон тонируется цветом `glow`.
    var tintsHeroGlow = true

    /// Лёгкий отсвет кромки кнопки профиля цветом зоны.
    var profileTint: Color { glow.opacity(Size.profileTintOpacity) }

    static let normal = AuraPalette(
        glow: Color(hex: 0x37F2B3), markerGlow: Color(hex: 0x37F2B3, opacity: 0.35), tintsHeroGlow: false
    )
    static let elevated = AuraPalette(glow: Color(hex: 0xFFC857), markerGlow: Color(hex: 0xFFC857, opacity: 0.35))
    static let high = AuraPalette(glow: Color(hex: 0xFF4D6A), markerGlow: Color(hex: 0xFF6B81, opacity: 0.35))
    static let noData = AuraPalette(glow: Color(hex: 0x5A6478), markerGlow: Color(hex: 0x8A93A6, opacity: 0.25))
}

extension HealthState {
    /// Палитра свечения для состояния.
    var palette: AuraPalette {
        switch self {
        case .normal: return .normal
        case .elevated: return .elevated
        case .high: return .high
        case .neutral, .noData: return .noData
        }
    }
}
