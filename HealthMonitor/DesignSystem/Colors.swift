import SwiftUI

extension Color {
    /// Внутренний инициализатор из hex. Используется только внутри DesignSystem/
    /// (SwiftLint запрещает `Color(hex` в остальном коде).
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}

/// Пара цветов статуса: текст и фон пилюли.
struct StatusColor {
    let text: Color
    let background: Color
}

/// Цветовые токены из docs/DESIGN.md.
enum AppColor {
    // Интерфейс
    static let background = Color(hex: 0xF3F4F8)
    static let surface = Color(hex: 0xFFFFFF)
    static let textPrimary = Color(hex: 0x14181F)
    static let textSecondary = Color(hex: 0x5A6472)
    static let textTertiary = Color(hex: 0xA3ABB7)
    static let border = Color(hex: 0xE3E6EB)
    static let fill = Color(hex: 0xEEF0F3)
    static let segmentTrack = Color(hex: 0xE7E9EF)
    static let accent = Color(hex: 0x1F5EFF)
    static let accentSoft = Color(hex: 0xE8EEFF)

    /// Цвет тени карточки (rgba(20,24,31,0.06)).
    static let shadow = Color(.sRGB, red: 20 / 255, green: 24 / 255, blue: 31 / 255, opacity: 0.06)

    // Статусы
    static let success = StatusColor(text: Color(hex: 0x1B7F4B), background: Color(hex: 0xE3F5EA))
    static let warning = StatusColor(text: Color(hex: 0x9A5B00), background: Color(hex: 0xFFF1D6))
    static let danger = StatusColor(text: Color(hex: 0xB42318), background: Color(hex: 0xFDE7E4))

    // Показатели
    static let pressure = Color(hex: 0x3B5BDB)
    static let pulse = Color(hex: 0xC2255C)
    static let weight = Color(hex: 0x0B7285)
    static let glucose = Color(hex: 0xC2410C)

    // Зоны на графике давления
    static let zoneNormal = Color(hex: 0xEAF6EE)
    static let zoneElevated = Color(hex: 0xFFF1D6)
    static let zoneHigh = Color(hex: 0xFDE7E4)
}

#Preview("Colors") {
    let ui: [(String, Color)] = [
        ("background", AppColor.background), ("surface", AppColor.surface),
        ("textPrimary", AppColor.textPrimary), ("textSecondary", AppColor.textSecondary),
        ("textTertiary", AppColor.textTertiary), ("border", AppColor.border),
        ("fill", AppColor.fill), ("segmentTrack", AppColor.segmentTrack),
        ("accent", AppColor.accent), ("accentSoft", AppColor.accentSoft),
        ("pressure", AppColor.pressure), ("pulse", AppColor.pulse),
        ("weight", AppColor.weight), ("glucose", AppColor.glucose),
        ("zoneNormal", AppColor.zoneNormal), ("zoneElevated", AppColor.zoneElevated),
        ("zoneHigh", AppColor.zoneHigh),
        ("success.text", AppColor.success.text), ("success.bg", AppColor.success.background),
        ("warning.text", AppColor.warning.text), ("warning.bg", AppColor.warning.background),
        ("danger.text", AppColor.danger.text), ("danger.bg", AppColor.danger.background)
    ]
    return ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 8) {
            ForEach(ui, id: \.0) { item in
                VStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.1)
                        .frame(height: 48)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColor.border))
                    Text(item.0).font(.caption2)
                }
            }
        }
        .padding(16)
    }
    .background(AppColor.background)
}
