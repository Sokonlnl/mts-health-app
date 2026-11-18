import SwiftUI

extension View {
    /// Передаёт смещение прокрутки (от верха, вниз положительное) в `offset`. Кладётся фоном содержимого `ScrollView`,
    /// у которого задано `.coordinateSpace(name: space)`. Значение ограничено диапазоном `0...maxOffset`.
    /// Читает положение через `onGeometryChange`: `frame(in:)` внутри `GeometryReader` не обновлялось при прокрутке,
    /// и смещение оставалось 0.
    func reportsScrollOffset(in space: String, offset: Binding<CGFloat>, maxOffset: CGFloat) -> some View {
        background(alignment: .top) {
            Color.clear.onGeometryChange(for: CGFloat.self) { proxy in
                -proxy.frame(in: .named(space)).minY
            } action: { value in
                // Значение зажато в 0...maxOffset: при оттягивании вниз и далеко за порогом состояние не меняется и экран
                // не перерисовывается на каждый кадр (иначе он оставался сдвинутым после оттягивания).
                offset.wrappedValue = min(max(value, 0), maxOffset)
            }
        }
    }
}

/// Подложка под статус-бар: до низа статус-бара сплошной цвет фона, ниже градиент к прозрачному на `Size.statusBarFadeExtra`,
/// чтобы контент при прокрутке не заезжал под часы и Wi-Fi.
/// `offset`: смещение прокрутки; у верха экрана подложки нет (свечение остаётся чистым), за `ramp` pt она проявляется полностью.
struct StatusBarFade: View {
    var color = AppColor.background
    /// Высота статус-бара (`safeAreaInsets.top`): сплошная часть.
    let solidHeight: CGFloat
    let offset: CGFloat
    var ramp = Size.statusBarFadeRamp

    private var progress: Double { Double(min(1, max(0, offset / ramp))) }
    private var totalHeight: CGFloat { solidHeight + Size.statusBarFadeExtra }

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: color, location: 0),
                .init(color: color, location: solidHeight / max(totalHeight, 1)),
                .init(color: color.opacity(0), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: totalHeight)
        .opacity(progress)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

extension View {
    /// Кладёт подложку под статус-бар поверх экрана (от самого верха, высота берётся из `safeAreaInsets.top`).
    func statusBarFade(offset: CGFloat, color: Color = AppColor.background) -> some View {
        overlay(alignment: .top) {
            GeometryReader { proxy in
                StatusBarFade(color: color, solidHeight: proxy.safeAreaInsets.top, offset: offset)
                    .offset(y: -proxy.safeAreaInsets.top)
            }
            .allowsHitTesting(false)
        }
    }
}

private struct StatusBarFadePreview: View {
    let offset: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            AppColor.textSecondary
            StatusBarFade(solidHeight: Size.iconButton, offset: offset)
        }
        .frame(height: Size.skeletonCard * 2)
    }
}

#Preview("StatusBarFade: у верха (нет подложки)") { StatusBarFadePreview(offset: 0) }
#Preview("StatusBarFade: на середине пути") { StatusBarFadePreview(offset: Size.statusBarFadeRamp / 2) }
#Preview("StatusBarFade: полностью") { StatusBarFadePreview(offset: Size.statusBarFadeRamp) }
