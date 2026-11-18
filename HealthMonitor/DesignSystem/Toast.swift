import SwiftUI

/// Короткое сообщение-подсказка («Скоро будет доступно») над плавающей навигацией: стеклянная капсула.
/// Появляется при непустом `message`, исчезает сама через `Motion.toastNanoseconds` и читается VoiceOver как объявление.
private struct ToastModifier: ViewModifier {
    @Binding var message: String?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let message {
                    ToastBubble(message: message)
                        .padding(.bottom, Size.toastBottom)
                        .padding(.horizontal, Spacing.screenMargin)
                        .transition(.opacity)
                }
            }
            .animation(Motion.standard, value: message)
            .task(id: message) {
                guard let current = message else { return }
                AccessibilityNotification.Announcement(current).post()
                try? await Task.sleep(nanoseconds: Motion.toastNanoseconds)
                if message == current { message = nil }
            }
    }
}

/// Сама капсула сообщения.
struct ToastBubble: View {
    let message: String

    var body: some View {
        Text(message)
            .textStyle(.bodyStrong)
            .foregroundStyle(AppColor.textPrimary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.m)
            .frame(minHeight: Spacing.minTapTarget)
            .glassBackground(in: Capsule())
            .accessibilityIdentifier("soon-toast")
    }
}

extension View {
    /// Показывает подсказку при непустом `message` (сбрасывает его сам).
    func toast(message: Binding<String?>) -> some View {
        modifier(ToastModifier(message: message))
    }
}

#Preview("Toast") {
    ToastBubble(message: "Скоро будет доступно")
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
