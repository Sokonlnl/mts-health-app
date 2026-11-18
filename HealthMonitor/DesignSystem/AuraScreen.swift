import SwiftUI

extension View {
    /// Нижняя панель поверх прокрутки: содержимое, под ним градиент к фону высотой `fadeHeight`.
    func auraBottomBar<Bar: View>(
        fadeColor: Color = AppColor.background,
        fadeHeight: CGFloat = Size.bottomFadeHeight,
        @ViewBuilder _ bar: () -> Bar
    ) -> some View {
        overlay(alignment: .bottom) {
            bar()
                .padding(.horizontal, Spacing.screenMargin)
                .padding(.bottom, Spacing.s)
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .contain)
                .background(alignment: .bottom) { BottomFade(color: fadeColor, height: fadeHeight).ignoresSafeArea(edges: .bottom) }
        }
    }
}

#Preview("AuraScreen: нижняя панель") {
    ScrollView {
        Color.clear.frame(height: 900)
            .background(alignment: .top) { DomeGlow(palette: .elevated).frame(height: Size.pressureHeroHeight) }
    }
    .background(AppColor.background)
    .auraBottomBar {
        GlowButton(title: "Кнопка внизу", icon: .system("plus"), action: {})
    }
}
