import SwiftUI

/// Появление элемента заставки: прозрачность 0 → 1 и подъём снизу на `Motion.introOffset`, элементы по очереди
/// (`Motion.introItem(index:)`, 0 первый). Анимация стартует, когда элемент появился на экране.
/// `isActive == false` (заставка сыграна, «Уменьшить движение», snapshot-тесты): элемент виден сразу, без сдвига.
private struct IntroRevealModifier: ViewModifier {
    let index: Int
    let isActive: Bool
    @State private var hasAppeared = false

    private var isShown: Bool { hasAppeared || !isActive }

    func body(content: Content) -> some View {
        content
            .opacity(isShown ? 1 : 0)
            .offset(y: isShown ? 0 : Motion.introOffset)
            .animation(Motion.introItem(index: index), value: hasAppeared)
            .onAppear { hasAppeared = true }
    }
}

extension View {
    /// Заставка: элемент появляется по очереди с номером `index`, пока `isActive`.
    func introReveal(index: Int, isActive: Bool) -> some View {
        modifier(IntroRevealModifier(index: index, isActive: isActive))
    }
}

#Preview("IntroReveal: по очереди и без движения") {
    VStack(spacing: Spacing.m) {
        ForEach(0..<4, id: \.self) { index in
            Text("Элемент \(index + 1)")
                .textStyle(.body)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, minHeight: Spacing.minTapTarget)
                .glassCard()
                .introReveal(index: index, isActive: true)
        }
        Text("Без заставки")
            .textStyle(.body)
            .foregroundStyle(AppColor.textPrimary)
            .introReveal(index: 0, isActive: false)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
