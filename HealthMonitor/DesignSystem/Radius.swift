import SwiftUI

/// Радиусы из docs/DESIGN.md.
enum Radius {
    static let pill: CGFloat = 999
    static let card: CGFloat = 28
    static let cardSmall: CGFloat = 24
    /// Скругление верха шторки.
    static let sheet: CGFloat = 32
    static let control: CGFloat = 20
}

#Preview("Radius") {
    let items: [(String, CGFloat)] = [
        ("pill", Radius.pill), ("card", Radius.card), ("cardSmall", Radius.cardSmall),
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
