import SwiftUI

/// Смещение прокрутки содержимого от верха (для проявления подложки под статус-баром).
struct ScrollOffsetKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    /// Передаёт вверх смещение прокрутки в системе координат `space` (кладётся фоном содержимого `ScrollView`).
    func reportsScrollOffset(in space: String) -> some View {
        background(alignment: .top) {
            GeometryReader { proxy in
                Color.clear.preference(key: ScrollOffsetKey.self, value: -proxy.frame(in: .named(space)).minY)
            }
        }
    }
}

/// Подложка под статус-бар: градиент от фона к прозрачному, чтобы контент при прокрутке не заезжал под часы и Wi-Fi.
/// `offset`: смещение прокрутки; у верха экрана подложки нет (свечение остаётся чистым), за `ramp` pt она проявляется полностью.
struct StatusBarFade: View {
    var color = AppColor.homeBackground
    let height: CGFloat
    let offset: CGFloat
    var ramp = Size.statusBarFadeRamp

    private var progress: Double { Double(min(1, max(0, offset / ramp))) }

    var body: some View {
        LinearGradient(colors: [color, color.opacity(0)], startPoint: .top, endPoint: .bottom)
            .frame(height: height)
            .opacity(progress)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

#Preview("StatusBarFade") {
    ZStack(alignment: .top) {
        AppColor.textSecondary
        StatusBarFade(height: Size.iconButton + Size.statusBarFadeExtra, offset: Size.statusBarFadeRamp)
    }
    .frame(height: 200)
}
