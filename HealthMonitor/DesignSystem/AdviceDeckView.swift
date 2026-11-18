import SwiftUI

/// Колода советов: сверху карточка, позади до двух настоящих карточек с содержимым (меньше на `adviceStackScaleStep`
/// за уровень, ниже на `adviceStackStep`). Свайп влево или вправо смахивает верхнюю: она улетает, а следующая, уже
/// лежащая под ней, вырастает и встаёт вперёд вместе с жестом (её содержимое видно сразу), колода уменьшается.
/// Смахнутая карточка не возвращается; когда смахнули все, вместо колоды небольшая серая кнопка
/// «Получить новые советы». Пружина `Motion.adviceSwipe`.
/// «Уменьшить движение»: без полёта и наклона, простая смена кроссфейдом. VoiceOver: одна связка с подписью
/// «Совет N из M», жест `accessibilityAdjustableAction` и действие «Убрать совет».
struct AdviceDeckView: View {
    /// Оставшиеся карточки, верхняя первая. Пусто: показывается кнопка обновления.
    let cards: [AdviceCardModel]
    /// Подпись положения для VoiceOver («Совет 1 из 4»).
    let positionText: String
    let onDismiss: () -> Void
    let onRefresh: () -> Void
    /// Идёт жест по колоде: родитель в это время не листает страницы своим свайпом.
    @Binding var isSwiping: Bool

    @State private var drag: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var progress: CGFloat { min(1, abs(drag) / Motion.adviceSwipeThreshold) }

    /// Видимые карточки колоды (верхняя и до двух позади), с уровнем глубины.
    private var visibleLevels: [(level: Int, model: AdviceCardModel)] {
        Array(cards.prefix(Size.adviceVisibleCards).enumerated().map { (level: $0.offset, model: $0.element) })
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
    }

    var body: some View {
        Group {
            if cards.isEmpty {
                refreshButton
            } else {
                stack
            }
        }
        .animation(reduceMotion ? nil : Motion.adviceSwipe, value: cards.isEmpty)
    }

    // MARK: - Колода

    private var stack: some View {
        ZStack(alignment: .bottom) {
            // Задние рисуются первыми. Ключ по `id` совета: при смахивании следующая карточка не пересоздаётся,
            // а плавно занимает место верхней.
            ForEach(visibleLevels.reversed(), id: \.model.id) { item in
                card(item.model, level: item.level)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint(HomeText.adviceDeckHint)
        .accessibilityAdjustableAction { _ in onDismiss() }
        .accessibilityAction(named: HomeText.adviceDismissAction, onDismiss)
    }

    private var accessibilityText: String {
        guard let top = cards.first else { return "" }
        let parts = [positionText, top.title, top.text, top.disclaimer ?? ""]
        return parts.filter { !$0.isEmpty }.joined(separator: ". ")
    }

    /// Карточка на глубине `level` (0 — верхняя). Задняя при жесте приближается к месту предыдущей: растёт и поднимается.
    /// Верхняя следует за пальцем и наклоняется, оставаясь непрозрачной. Жест и нажатия только у верхней.
    private func card(_ model: AdviceCardModel, level: Int) -> some View {
        let isTop = level == 0
        let shown = CGFloat(level) - (reduceMotion || isTop ? 0 : progress)
        return AdviceCard(
            title: model.title, text: model.text, author: model.author, role: model.role,
            iconName: model.iconName, disclaimer: model.disclaimer
        )
        .overlay {
            // Задние карточки чуть темнее, чтобы глубина читалась.
            shape.fill(AppColor.background.opacity(Size.adviceBackDim * shown)).allowsHitTesting(false)
        }
        .scaleEffect(1 - Size.adviceStackScaleStep * shown, anchor: .bottom)
        .offset(x: isTop && !reduceMotion ? drag : 0, y: Size.adviceStackStep * shown)
        .rotationEffect(.degrees(isTop && !reduceMotion ? Double(drag / Motion.adviceTiltDivisor) : 0), anchor: .bottom)
        .transition(.opacity)
        .gesture(swipe, including: isTop ? .all : .none)
        .allowsHitTesting(isTop)
    }

    private var swipe: some Gesture {
        DragGesture(minimumDistance: Spacing.s)
            .onChanged { value in
                isSwiping = true
                drag = value.translation.width
            }
            .onEnded { value in
                // Сброс на следующем такте: родительский свайп страниц в этот же момент ещё видит, что жест был по колоде.
                Task { @MainActor in isSwiping = false }
                let width = value.translation.width
                guard abs(width) > Motion.adviceSwipeThreshold else {
                    withAnimation(reduceMotion ? nil : Motion.adviceSwipe) { drag = 0 }
                    return
                }
                dismiss(toLeft: width < 0)
            }
    }

    /// Карточка улетает за край; затем без анимации и одновременно она убирается из колоды и жест сбрасывается.
    /// К этому моменту следующая карточка уже выросла до размера верхней (прогресс жеста 1), поэтому кадр до и после
    /// совпадает и скачка нет. Раньше жест сбрасывался раньше перестановки, и следующая карточка на миг сжималась обратно.
    private func dismiss(toLeft: Bool) {
        if reduceMotion {
            withAnimation(Motion.fast) { onDismiss() }
            return
        }
        withAnimation(Motion.adviceSwipe, completionCriteria: .logicallyComplete) {
            drag = (toLeft ? -1 : 1) * Motion.adviceFlyOut
        } completion: {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                onDismiss()
                drag = 0
            }
        }
    }

    // MARK: - Пустая колода

    /// Небольшая серая кнопка по центру места, где была колода (высота не меняется, страница не «прыгает»).
    private var refreshButton: some View {
        Button(action: onRefresh) {
            Text(HomeText.adviceRefresh)
                .textStyle(.label)
                .foregroundStyle(AppColor.textSecondary)
                .padding(.horizontal, Spacing.l)
                .frame(minHeight: Spacing.minTapTarget)
                .background(AppColor.fill, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("advice-refresh")
        .frame(maxWidth: .infinity, minHeight: Size.adviceHeight)
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }
}

private struct AdviceDeckPreview: View {
    @State private var deck = AdviceDeck()
    @State private var isSwiping = false
    private let items = MockHealthData.advice.map {
        AdviceCardModel(
            id: $0.id, title: $0.title, text: $0.text, author: "ГигаЧат", role: "Медицинский помощник",
            iconName: HomeText.gigachatMarkAsset, disclaimer: nil
        )
    }

    var body: some View {
        AdviceDeckView(
            cards: deck.remaining(items),
            positionText: HomeText.advicePosition(deck.position(count: items.count), of: items.count),
            onDismiss: { deck.dismissTop(count: items.count) }, onRefresh: { deck.refresh(count: items.count) },
            isSwiping: $isSwiping
        )
        .padding(.horizontal, Spacing.screenMargin + Spacing.adviceInset)
        .padding(.bottom, Spacing.xxl)
        .background(AppColor.background)
    }
}

#Preview("AdviceDeckView: свайп и обновление") { AdviceDeckPreview() }
