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
    /// Плитка Figma: белый 3%, свечение в правом нижнем углу, градиентная кромка 1 pt. Без материала.
    case tile
    /// Кнопка профиля Figma: как плитка, но кромка ярче (до белого 70%).
    case profile
}

/// Единая стеклянная поверхность для любой формы. Вид задаёт `GlassStyle`.
struct GlassSurface<S: InsettableShape>: View {
    let shape: S
    var style: GlassStyle = .material

    var body: some View {
        Group {
            switch style {
            case .material:
                material
            case .tile:
                tile(
                    fill: AppColor.tileFill,
                    rim: [AppColor.tileRimTop, AppColor.tileRimMid, AppColor.tileRimBottom],
                    glowRadius: Size.tileGlowRadius
                )
            case .profile:
                tile(
                    fill: AppColor.profileFill,
                    rim: [AppColor.profileRimTop, AppColor.profileRimMid, AppColor.profileRimBottom],
                    glowRadius: Size.profileGlowRadius
                )
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
        }
    }
}

extension View {
    /// Стеклянный фон для любой формы (круг, капсула, скруглённый прямоугольник).
    func glassBackground<S: InsettableShape>(in shape: S, style: GlassStyle = .material) -> some View {
        background { GlassSurface(shape: shape, style: style) }
    }

    /// Стеклянная плитка бенто: заполняет отданное место (высоту задаёт `BentoGrid`), не ниже `tileHeight`.
    func glassTile(radius: CGFloat = Radius.tile) -> some View {
        frame(maxWidth: .infinity, minHeight: Size.tileHeight, maxHeight: .infinity)
            .glassBackground(in: RoundedRectangle(cornerRadius: radius, style: .continuous), style: .tile)
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
