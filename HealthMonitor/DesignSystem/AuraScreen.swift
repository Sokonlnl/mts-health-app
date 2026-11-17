import SwiftUI

extension View {
    /// Фон экрана Aura: свечение вверху (кладётся фоном внутрь прокрутки, уезжает вместе с содержимым).
    /// Высота блока: `Size.glowPressureHeight`. Главный экран использует `DomeGlow`.
    func auraScreenBackdrop(palette: AuraPalette, glowHeight: CGFloat) -> some View {
        background(alignment: .top) { TopGlow(palette: palette, height: glowHeight) }
    }

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
                .background(alignment: .bottom) { BottomFade(color: fadeColor, height: fadeHeight).ignoresSafeArea(edges: .bottom) }
        }
    }
}

#Preview("AuraScreen: фон и нижняя панель") {
    ScrollView {
        Color.clear.frame(height: 900)
            .auraScreenBackdrop(palette: .elevated, glowHeight: Size.glowPressureHeight)
    }
    .background(AppColor.background)
    .auraBottomBar {
        PrimaryButton(title: "Добавить измерение", style: .glass, action: {})
    }
}
