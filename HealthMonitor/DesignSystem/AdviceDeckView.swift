import SwiftUI

/// Галерея-колода советов: сверху карточка, позади две узкие (уже на `adviceStackInset` с каждой стороны, ниже на
/// `adviceStackStep`). Свайп влево или вправо смахивает верхнюю: она улетает, задняя выезжает вперёд (сдвиг и ширина
/// растут вместе с жестом), смахнутая уходит в конец колоды (порядок считает `AdviceDeck` во ViewModel). Пружина `Motion.adviceSwipe`.
/// «Уменьшить движение»: без полёта и наклона, простая смена кроссфейдом. VoiceOver: одна связка с подписью «Совет N из M»,
/// жест `accessibilityAdjustableAction` и действия «Следующий совет», «Предыдущий совет».
struct AdviceDeckView: View {
    let cards: [AdviceCardModel]
    /// Подпись положения для VoiceOver («Совет 1 из 4»).
    let positionText: String
    let onNext: () -> Void
    let onPrevious: () -> Void

    @State private var drag: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var progress: CGFloat { min(1, abs(drag) / Motion.adviceSwipeThreshold) }
    private var backLevels: [Int] { Array((1...2).reversed()).filter { $0 < cards.count } }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(backLevels, id: \.self) { level in
                // Задняя карточка при жесте приближается к месту предыдущей.
                let shown = CGFloat(level) - (reduceMotion ? 0 : progress)
                GlassSurface(shape: shape, style: .solid)
                    .padding(.horizontal, Size.adviceStackInset * shown)
                    .offset(y: Size.adviceStackStep * shown)
            }
            if let top = cards.first {
                card(top)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint(HomeText.adviceDeckHint)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: onNext()
            case .decrement: onPrevious()
            @unknown default: break
            }
        }
        .accessibilityAction(named: HomeText.adviceNextAction, onNext)
        .accessibilityAction(named: HomeText.advicePreviousAction, onPrevious)
    }

    private var accessibilityText: String {
        guard let top = cards.first else { return "" }
        let parts = [positionText, top.title, top.text, top.disclaimer ?? ""]
        return parts.filter { !$0.isEmpty }.joined(separator: ". ")
    }

    private func card(_ model: AdviceCardModel) -> some View {
        AdviceCard(
            title: model.title, text: model.text, author: model.author, role: model.role,
            iconName: model.iconName, disclaimer: model.disclaimer
        )
        .id(model.id)
        .offset(x: reduceMotion ? 0 : drag)
        .rotationEffect(.degrees(reduceMotion ? 0 : Double(drag / Motion.adviceTiltDivisor)))
        .opacity(1 - 0.5 * progress)
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
        .gesture(swipe)
    }

    private var swipe: some Gesture {
        DragGesture(minimumDistance: Spacing.s)
            .onChanged { value in
                if cards.count > 1 { drag = value.translation.width }
            }
            .onEnded { value in
                let width = value.translation.width
                guard cards.count > 1, abs(width) > Motion.adviceSwipeThreshold else {
                    withAnimation(reduceMotion ? nil : Motion.adviceSwipe) { drag = 0 }
                    return
                }
                dismiss(forward: width < 0)
            }
    }

    /// Карточка улетает за край, затем колода переставляется, а жест сбрасывается без анимации.
    private func dismiss(forward: Bool) {
        if reduceMotion {
            withAnimation(Motion.fast) { advance(forward: forward) }
            return
        }
        withAnimation(Motion.adviceSwipe, completionCriteria: .logicallyComplete) {
            drag = (forward ? -1 : 1) * Motion.adviceFlyOut
        } completion: {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { drag = 0 }
            withAnimation(Motion.adviceSwipe) { advance(forward: forward) }
        }
    }

    private func advance(forward: Bool) {
        if forward { onNext() } else { onPrevious() }
    }
}

private struct AdviceDeckPreview: View {
    @State private var deck = AdviceDeck()
    private let items = MockHealthData.advice.map {
        AdviceCardModel(
            id: $0.id, title: $0.title, text: $0.text, author: "ГигаЧат", role: "Медицинский помощник",
            iconName: "sparkles", disclaimer: nil
        )
    }

    var body: some View {
        AdviceDeckView(
            cards: deck.ordered(items), positionText: HomeText.advicePosition(deck.position(count: items.count), of: items.count),
            onNext: { deck.next(count: items.count) }, onPrevious: { deck.previous(count: items.count) }
        )
        .padding(.horizontal, Spacing.screenMargin + Spacing.adviceInset)
        .padding(.bottom, Spacing.xxl)
        .background(AppColor.background)
    }
}

#Preview("AdviceDeckView: свайп") { AdviceDeckPreview() }
