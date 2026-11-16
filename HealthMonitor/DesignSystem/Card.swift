import SwiftUI

/// Белая карточка с мягкой тенью.
struct CardStyle: ViewModifier {
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(AppColor.surface, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .cardShadow()
    }
}

extension View {
    /// Оформляет вью как карточку: `.cardStyle()` или `.cardStyle(radius: Radius.hero)`.
    func cardStyle(radius: CGFloat = Radius.card) -> some View {
        modifier(CardStyle(radius: radius))
    }
}

#Preview("Card") {
    VStack(spacing: Spacing.l) {
        Text("Карточка card 20")
            .textStyle(.body)
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
        Text("Карточка hero 24")
            .textStyle(.body)
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle(radius: Radius.hero)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
