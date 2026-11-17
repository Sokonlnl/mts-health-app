import SwiftUI

/// Появление нового содержимого при смене ключа: прозрачность, сдвиг вниз на 8 pt, масштаб 0,98 (`Motion.contentSwap`).
/// При «Уменьшить движение» остаётся кроссфейд без сдвига и масштаба.
private struct ContentSwapModifier<Key: Hashable>: ViewModifier {
    let key: Key
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        ZStack {
            content
                .id(key)
                .transition(reduceMotion ? AnyTransition.opacity : Motion.contentSwapTransition)
        }
        .animation(reduceMotion ? Motion.fast : Motion.contentSwap, value: key)
    }
}

extension View {
    /// Анимирует смену содержимого при изменении `key` (значение показателя, период, заголовок).
    func contentSwap<Key: Hashable>(_ key: Key) -> some View {
        modifier(ContentSwapModifier(key: key))
    }
}

private struct ContentSwapDemo: View {
    @State private var value = 122

    var body: some View {
        VStack(spacing: Spacing.l) {
            Text("\(value)")
                .textStyle(.heroValue)
                .foregroundStyle(AppColor.textPrimary)
                .contentSwap(value)
            Button("Изменить") { value += 3 }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}

#Preview("ContentSwap") {
    ContentSwapDemo()
}
