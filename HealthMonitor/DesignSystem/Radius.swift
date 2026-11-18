import SwiftUI

/// Радиусы из docs/DESIGN.md.
enum Radius {
    /// Скругление верха шторки.
    static let sheet: CGFloat = 32
    static let control: CGFloat = 20
    /// Малые карточки (вес, глюкоза) и карточка совета.
    static let tile: CGFloat = 33.4
    /// Кнопка с зелёным свечением.
    static let glowButton: CGFloat = 21
    /// Большая карточка давления.
    static let heroCard: CGFloat = 48
    /// Полосы мини-шкалы веса.
    static let gauge: CGFloat = 7
    /// Скругление низа верхнего блока со свечением.
    static let hero: CGFloat = 42
}

#Preview("Radius") {
    let items: [(String, CGFloat)] = [
        ("tile", Radius.tile), ("heroCard", Radius.heroCard), ("hero", Radius.hero),
        ("sheet", Radius.sheet), ("control", Radius.control)
    ]
    return VStack(spacing: Spacing.m) {
        ForEach(items, id: \.0) { item in
            Text("\(item.0) \(Int(item.1))")
                .textStyle(.label)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, minHeight: 56)
                .glassBackground(in: RoundedRectangle(cornerRadius: item.1, style: .continuous))
        }
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
