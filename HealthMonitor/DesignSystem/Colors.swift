import SwiftUI

extension Color {
    /// Внутренний инициализатор из hex. Используется только внутри DesignSystem/
    /// (SwiftLint запрещает `Color(hex` в остальном коде).
    init(hex: UInt32, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

/// Цвета статуса: текст, фон плашки и контур.
struct StatusColor {
    let text: Color
    let background: Color
    let stroke: Color
}

/// Цветовые токены из docs/DESIGN.md (тёмная тема Aura).
enum AppColor {
    // Интерфейс
    static let background = Color(hex: 0x06070B)
    static let textPrimary = Color(hex: 0xF4F6FA)
    static let textSecondary = Color(hex: 0xAEB6C6)
    static let textTertiary = Color(hex: 0x8A93A6)
    static let primaryFill = Color(hex: 0xF4F6FA)
    static let primaryText = Color(hex: 0x06070B)
    static let scrim = Color.black.opacity(0.55)
    static let hairline = Color.white.opacity(0.08)

    // Стекло
    static let glassFillTop = Color.white.opacity(0.10)
    static let glassFillBottom = Color.white.opacity(0.03)
    static let glassStroke = Color.white.opacity(0.12)
    static let glassHighlight = Color.white.opacity(0.22)
    static let shadow = Color.black.opacity(0.40)
    /// Тень текста значения на свечении формы.
    static let textShadow = Color.black.opacity(0.25)
    /// Затемнение под текстом в центре формы Aura: контраст текста не ниже 4.5:1 на светлом градиенте.
    static let orbScrim = Color.black.opacity(0.5)
    /// Тонировка шторки поверх материала.
    static let sheetTint = Color(hex: 0x06070B, opacity: 0.60)

    // Главный экран (эталон Figma 47:2127)
    static let homeBackground = Color(hex: 0x000000)
    /// Стеклянная плитка: заливка 3%, свечение в правом нижнем углу и градиентная кромка 1 pt
    /// (ярко сверху-слева, слабо в середине, заметно снизу-справа).
    static let tileFill = Color.white.opacity(0.03)
    static let tileInnerGlow = Color.white.opacity(0.14)
    static let tileRimTop = Color.white.opacity(0.32)
    static let tileRimMid = Color.white.opacity(0.05)
    static let tileRimBottom = Color.white.opacity(0.22)
    /// Кнопка профиля: заливка и кромка (ярче плитки).
    static let profileFill = Color.white.opacity(0.03)
    static let profileRimTop = Color.white.opacity(0.7)
    static let profileRimMid = Color.white.opacity(0.15)
    static let profileRimBottom = Color.white.opacity(0.5)
    /// Кнопка с зелёным свечением (GlowButton).
    static let glowButtonFill = Color(hex: 0x0F0034, opacity: 0.23)
    static let glowButtonEdge = Color(hex: 0x13D694)
    static let glowButtonDeep = Color(hex: 0x002F1F)
    /// Тёмная карточка показателя (`MetricCard` с `surface: .solid`).
    static let solidCardFill = Color(hex: 0x202020)
    static let solidCardStroke = Color(hex: 0x383838)

    // Заливки элементов управления
    static let fill = Color.white.opacity(0.08)
    static let fillSelected = Color.white.opacity(0.14)
    static let segmentActive = Color.white.opacity(0.16)
    static let orbRing = Color.white.opacity(0.18)

    // Статусы (цвет текста; фон плашки белый 8%, контур белый 14%)
    static let success = status(0x5BF0B8)
    static let warning = status(0xFFC857)
    static let danger = status(0xFF6B81)
    static let neutral = status(0x9AA3B5)

    // Показатели
    static let pressure = Color(hex: 0x7B8CFF)
    static let pulse = Color(hex: 0xFF6F9C)
    static let weight = Color(hex: 0x4FD4E6)
    static let glucose = Color(hex: 0xFF9B5E)

    // График давления
    static let zoneNormal = Color(hex: 0x37F2B3, opacity: 0.09)
    static let zoneElevated = Color(hex: 0xFFC857, opacity: 0.16)
    static let zoneHigh = Color(hex: 0xFF6B81, opacity: 0.16)
    static let zoneLineElevated = Color(hex: 0xFFC857, opacity: 0.50)
    static let zoneLineHigh = Color(hex: 0xFF6B81, opacity: 0.50)
    static let chartUpper = Color(hex: 0xF4F6FA)
    static let chartLower = Color(hex: 0xA0BEFF, opacity: 0.75)

    private static func status(_ hex: UInt32) -> StatusColor {
        StatusColor(text: Color(hex: hex), background: Color.white.opacity(0.08), stroke: Color.white.opacity(0.14))
    }
}

#Preview("Colors") {
    let ui: [(String, Color)] = [
        ("background", AppColor.background), ("textPrimary", AppColor.textPrimary),
        ("textSecondary", AppColor.textSecondary), ("textTertiary", AppColor.textTertiary),
        ("primaryFill", AppColor.primaryFill), ("glassFillTop", AppColor.glassFillTop),
        ("glassStroke", AppColor.glassStroke), ("fill", AppColor.fill),
        ("fillSelected", AppColor.fillSelected), ("segmentActive", AppColor.segmentActive),
        ("pressure", AppColor.pressure), ("pulse", AppColor.pulse),
        ("weight", AppColor.weight), ("glucose", AppColor.glucose),
        ("zoneNormal", AppColor.zoneNormal), ("zoneElevated", AppColor.zoneElevated),
        ("zoneHigh", AppColor.zoneHigh),
        ("success", AppColor.success.text), ("warning", AppColor.warning.text),
        ("danger", AppColor.danger.text), ("neutral", AppColor.neutral.text)
    ]
    return ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 8) {
            ForEach(ui, id: \.0) { item in
                VStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.1)
                        .frame(height: 48)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColor.glassStroke))
                    Text(item.0).font(.caption2).foregroundStyle(AppColor.textSecondary)
                }
            }
        }
        .padding(16)
    }
    .background(AppColor.background)
}
