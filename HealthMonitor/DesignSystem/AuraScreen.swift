import SwiftUI

extension View {
    /// Фон экрана Aura: свечение вверху (кладётся фоном внутрь прокрутки, уезжает вместе с содержимым).
    /// Высота блока: `Size.glowHomeHeight` на главном экране, `Size.glowPressureHeight` на экране давления.
    func auraScreenBackdrop(palette: AuraPalette, glowHeight: CGFloat) -> some View {
        background(alignment: .top) { TopGlow(palette: palette, height: glowHeight) }
    }

    /// Нижняя панель поверх прокрутки: содержимое, под ним градиент к фону высотой `Spacing.tabBarClearance`.
    func auraBottomBar<Bar: View>(@ViewBuilder _ bar: () -> Bar) -> some View {
        overlay(alignment: .bottom) {
            bar()
                .padding(.horizontal, Spacing.screenMargin)
                .padding(.bottom, Spacing.s)
                .frame(maxWidth: .infinity)
                .background(alignment: .bottom) { BottomFade().ignoresSafeArea(edges: .bottom) }
        }
    }
}

#Preview("AuraScreen: фон и нижняя панель") {
    ScrollView {
        Color.clear.frame(height: 900)
            .auraScreenBackdrop(palette: .elevated, glowHeight: Size.glowHomeHeight)
    }
    .background(AppColor.background)
    .auraBottomBar {
        PrimaryButton(title: "Добавить измерение", style: .glass, action: {})
    }
}
