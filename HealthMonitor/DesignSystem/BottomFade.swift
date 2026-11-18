import SwiftUI

/// Градиент к фону над плавающей навигацией и внизу экрана: контент гаснет, внизу чистый тёмный фон.
/// Прозрачный сверху, 35% на 30%, 80% на 55%, сплошной на 85% высоты (без плоской обрезки контента над кнопкой).
struct BottomFade: View {
    var color = AppColor.background
    var height = Size.bottomFadeHeight

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: color.opacity(0), location: 0),
                .init(color: color.opacity(0.35), location: 0.3),
                .init(color: color.opacity(0.8), location: 0.55),
                .init(color: color, location: 0.85)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: height)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview("BottomFade") {
    ZStack(alignment: .bottom) {
        AppColor.textSecondary
        BottomFade()
    }
    .background(AppColor.background)
}
