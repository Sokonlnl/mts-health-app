import SwiftUI

/// Внутренние отступы карточки.
enum CardInsets {
    /// Стандартные: 16 со всех сторон.
    static let standard = EdgeInsets(top: Spacing.l, leading: Spacing.l, bottom: Spacing.l, trailing: Spacing.l)
    /// Для сообщений о состоянии: 20.
    static let message = EdgeInsets(top: Spacing.xl, leading: Spacing.xl, bottom: Spacing.xl, trailing: Spacing.xl)
    /// Для недели в строке: 12 по вертикали, 8 по горизонтали.
    static let compact = EdgeInsets(top: Spacing.m, leading: Spacing.s, bottom: Spacing.m, trailing: Spacing.s)
    /// Для списков со строками, у которых свои вертикальные отступы.
    static let list = EdgeInsets(top: 0, leading: Spacing.l, bottom: 0, trailing: Spacing.l)
}

/// Белая карточка с мягкой тенью: паддинг, ширина по контейнеру, фон, тень.
struct CardStyle: ViewModifier {
    let radius: CGFloat
    let insets: EdgeInsets

    func body(content: Content) -> some View {
        content
            .padding(insets)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.surface, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .cardShadow()
    }
}

extension View {
    /// Оформляет вью как карточку: `.cardStyle()` или `.cardStyle(radius: Radius.hero)`.
    /// Паддинг входит в стиль, снаружи его добавлять не нужно.
    func cardStyle(radius: CGFloat = Radius.card, insets: EdgeInsets = CardInsets.standard) -> some View {
        modifier(CardStyle(radius: radius, insets: insets))
    }
}

#Preview("Card") {
    VStack(spacing: Spacing.l) {
        Text("Карточка card 20")
            .textStyle(.body)
            .cardStyle()
        Text("Карточка hero 24")
            .textStyle(.body)
            .cardStyle(radius: Radius.hero)
        Text("Карточка compact")
            .textStyle(.body)
            .cardStyle(insets: CardInsets.compact)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
