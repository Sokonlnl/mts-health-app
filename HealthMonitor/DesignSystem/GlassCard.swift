import SwiftUI

/// Внутренние отступы стеклянной карточки.
enum CardInsets {
    /// Стандартные: 18 со всех сторон.
    static let standard = EdgeInsets(
        top: Spacing.cardPadding, leading: Spacing.cardPadding, bottom: Spacing.cardPadding, trailing: Spacing.cardPadding
    )
    /// Компактные: 16 со всех сторон (малые карточки).
    static let compact = EdgeInsets(top: Spacing.l, leading: Spacing.l, bottom: Spacing.l, trailing: Spacing.l)
    /// Для сообщений о состоянии: 20.
    static let message = EdgeInsets(top: Spacing.xl, leading: Spacing.xl, bottom: Spacing.xl, trailing: Spacing.xl)
    /// Для списков со своими строками: 6 по вертикали, 18 по горизонтали.
    static let list = EdgeInsets(
        top: Spacing.cardListVertical, leading: Spacing.cardPadding, bottom: Spacing.cardListVertical, trailing: Spacing.cardPadding
    )
}

/// Материал «жидкое стекло»: `ultraThinMaterial`, градиент заливки, контур, верхняя кромка, тень.
struct GlassSurface<S: InsettableShape>: View {
    let shape: S

    var body: some View {
        ZStack {
            shape.fill(.ultraThinMaterial)
            shape.fill(
                LinearGradient(
                    colors: [AppColor.glassFillTop, AppColor.glassFillBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            shape.strokeBorder(AppColor.glassStroke, lineWidth: Size.hairline)
            shape.strokeBorder(
                LinearGradient(colors: [AppColor.glassHighlight, Color.clear], startPoint: .top, endPoint: .center),
                lineWidth: Size.hairline
            )
        }
        .shadow(color: AppColor.shadow, radius: Size.glassShadow)
        .accessibilityHidden(true)
    }
}

extension View {
    /// Стеклянный фон для любой формы (круг, капсула, скруглённый прямоугольник).
    func glassBackground<S: InsettableShape>(in shape: S) -> some View {
        background { GlassSurface(shape: shape) }
    }

    /// Оформляет вью как стеклянную карточку: `.glassCard()` или `.glassCard(radius: Radius.cardSmall)`.
    /// Паддинг входит в стиль, снаружи его добавлять не нужно.
    func glassCard(radius: CGFloat = Radius.card, insets: EdgeInsets = CardInsets.standard) -> some View {
        padding(insets)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassBackground(in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

#Preview("GlassCard") {
    ZStack {
        AppColor.background.ignoresSafeArea()
        TopGlow(palette: .normal, height: Size.glowPressureHeight)
        VStack(spacing: Spacing.l) {
            Text("Карточка card 28")
                .textStyle(.body)
                .foregroundStyle(AppColor.textPrimary)
                .glassCard()
            Text("Карточка cardSmall 24, compact")
                .textStyle(.body)
                .foregroundStyle(AppColor.textPrimary)
                .glassCard(radius: Radius.cardSmall, insets: CardInsets.compact)
            Text("Карточка-список")
                .textStyle(.body)
                .foregroundStyle(AppColor.textPrimary)
                .glassCard(insets: CardInsets.list)
        }
        .padding(Spacing.screenMargin)
    }
}
