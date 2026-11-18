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

/// Вид стеклянной поверхности.
enum GlassStyle {
    /// «Жидкое стекло»: `ultraThinMaterial`, градиент заливки, контур, верхняя кромка, тень (карточки, навигация).
    case material
    /// Кнопка профиля Figma: как плитка, но кромка ярче (до белого 70%).
    case profile
    /// Большая карточка давления: белый 3%, свечение справа внизу, кромка 1 pt белый 55% сверху-слева и снизу-справа.
    case hero
    /// Малая карточка: заливка белый 6%, кромка белый 5% 0,8 pt.
    case flat
    /// Тёмная карточка совета: заливка #1B1B1B, кромка белый 5%.
    case solid
}

/// Единая стеклянная поверхность для любой формы. Вид задаёт `GlassStyle`.
struct GlassSurface<S: InsettableShape>: View {
    let shape: S
    var style: GlassStyle = .material
    /// Отсвет кромки поверх градиента (кнопка профиля).
    var tint: Color?

    var body: some View {
        Group {
            switch style {
            case .material:
                material
            case .profile:
                tile(
                    fill: AppColor.profileFill,
                    rim: [AppColor.profileRimTop, AppColor.profileRimMid, AppColor.profileRimBottom],
                    glowRadius: Size.profileGlowRadius
                )
            case .hero:
                tile(
                    fill: AppColor.tileFill,
                    rim: [AppColor.heroCardRim, AppColor.tileRimMid, AppColor.heroCardRim],
                    glowRadius: Size.tileGlowRadius
                )
            case .flat:
                plate(fill: AppColor.flatFill, stroke: AppColor.flatStroke, lineWidth: Size.flatRim)
            case .solid:
                plate(fill: AppColor.solidCardFill, stroke: AppColor.solidCardStroke, lineWidth: Size.hairline)
            }
        }
        .accessibilityHidden(true)
    }

    private var material: some View {
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
    }

    /// Плоская карточка: заливка и тонкая кромка.
    private func plate(fill: Color, stroke: Color, lineWidth: CGFloat) -> some View {
        ZStack {
            shape.fill(fill)
            shape.strokeBorder(stroke, lineWidth: lineWidth)
        }
    }

    /// Плитка Figma: заливка, мягкое свечение в правом нижнем углу и градиентная кромка 1 pt.
    /// Радиальное свечение и обводка (а не `.shadow(.inner)`) видны и на чёрном фоне.
    private func tile(fill: Color, rim: [Color], glowRadius: CGFloat) -> some View {
        ZStack {
            shape.fill(fill)
            shape.fill(
                RadialGradient(
                    colors: [AppColor.tileInnerGlow, Color.clear],
                    center: .bottomTrailing,
                    startRadius: 0,
                    endRadius: glowRadius
                )
            )
            shape.strokeBorder(
                LinearGradient(colors: rim, startPoint: .topLeading, endPoint: .bottomTrailing),
                lineWidth: Size.hairline
            )
            if let tint {
                shape.strokeBorder(tint, lineWidth: Size.hairline)
            }
        }
    }
}

extension View {
    /// Стеклянный фон для любой формы (круг, капсула, скруглённый прямоугольник).
    func glassBackground<S: InsettableShape>(in shape: S, style: GlassStyle = .material, tint: Color? = nil) -> some View {
        background { GlassSurface(shape: shape, style: style, tint: tint) }
    }

    /// Оформляет вью как карточку: `.glassCard()` или `.glassCard(radius: Radius.heroCard, style: .hero)`.
    /// Паддинг входит в стиль, снаружи его добавлять не нужно.
    /// По умолчанию материал малых карточек нового главного экрана (`.flat`: белый 6%, кромка 5%, радиус 33,4).
    func glassCard(
        radius: CGFloat = Radius.tile, insets: EdgeInsets = CardInsets.standard, style: GlassStyle = .flat
    ) -> some View {
        padding(insets)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassBackground(in: RoundedRectangle(cornerRadius: radius, style: .continuous), style: style)
    }
}

#Preview("GlassCard") {
    ZStack {
        AppColor.background.ignoresSafeArea()
        DomeGlow(palette: .normal)
            .frame(height: Size.pressureHeroHeight)
            .frame(maxHeight: .infinity, alignment: .top)
        VStack(spacing: Spacing.l) {
            Text("Карточка tile 33,4")
                .textStyle(.body)
                .foregroundStyle(AppColor.textPrimary)
                .glassCard()
            Text("Карточка compact, материал")
                .textStyle(.body)
                .foregroundStyle(AppColor.textPrimary)
                .glassCard(insets: CardInsets.compact, style: .material)
            Text("Карточка-список")
                .textStyle(.body)
                .foregroundStyle(AppColor.textPrimary)
                .glassCard(insets: CardInsets.list)
        }
        .padding(Spacing.screenMargin)
    }
}
