import SwiftUI

/// Радиусы из docs/DESIGN.md.
enum Radius {
    static let pill: CGFloat = 999
    static let card: CGFloat = 20
    static let hero: CGFloat = 24
    static let sheet: CGFloat = 28
    /// Контролы: 14–16.
    static let control: CGFloat = 14
    static let controlLarge: CGFloat = 16
}

/// Тень карточки: 0 6 20 rgba(20,24,31,0.06).
enum CardShadow {
    static let radius: CGFloat = 20
    static let offsetY: CGFloat = 6
}

extension View {
    /// Мягкая тень карточки из дизайн-системы.
    func cardShadow() -> some View {
        shadow(color: AppColor.shadow, radius: CardShadow.radius, x: 0, y: CardShadow.offsetY)
    }
}

#Preview("Radius") {
    let items: [(String, CGFloat)] = [
        ("pill", Radius.pill), ("card", Radius.card), ("hero", Radius.hero),
        ("sheet", Radius.sheet), ("control", Radius.control), ("controlLarge", Radius.controlLarge)
    ]
    return VStack(spacing: Spacing.m) {
        ForEach(items, id: \.0) { item in
            Text("\(item.0) \(Int(item.1))")
                .textStyle(.label)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(AppColor.surface, in: RoundedRectangle(cornerRadius: item.1))
                .cardShadow()
        }
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
