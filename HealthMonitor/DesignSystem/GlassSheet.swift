import SwiftUI

/// Шторка из тёмного стекла: подложка scrim 55% и панель со скруглением 32 сверху.
/// Выезд за `Motion.sheet`, подложка за `Motion.sheetScrim`. Закрывается нажатием на подложку,
/// жестом вниз за ручку и жестом «Escape» VoiceOver.
private struct GlassSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheet: SheetContent
    @State private var dragOffset: CGFloat = 0

    private var panelShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: Radius.sheet,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: Radius.sheet,
            style: .continuous
        )
    }

    func body(content: Content) -> some View {
        content
            .accessibilityHidden(isPresented)
            .overlay {
                ZStack(alignment: .bottom) {
                    if isPresented {
                        AppColor.scrim
                            .ignoresSafeArea()
                            .onTapGesture { isPresented = false }
                            .transition(.opacity.animation(Motion.sheetScrim))
                            .accessibilityHidden(true)
                        panel
                            .transition(.move(edge: .bottom).animation(Motion.sheet))
                    }
                }
                .animation(Motion.sheet, value: isPresented)
            }
    }

    private var panel: some View {
        VStack(spacing: 0) {
            dragHandle
            sheet
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                panelShape.fill(.ultraThinMaterial)
                panelShape.fill(AppColor.sheetTint)
                panelShape.stroke(AppColor.glassStroke, lineWidth: Size.hairline)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .padding(.top, Spacing.xxl * 2)
        .offset(y: dragOffset)
        .preferredColorScheme(.dark)
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape) { isPresented = false }
    }

    private var dragHandle: some View {
        Capsule()
            .fill(AppColor.textTertiary)
            .frame(width: Size.dragHandleWidth, height: Size.dragHandleHeight)
            .frame(maxWidth: .infinity, minHeight: Spacing.minTapTarget)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = max(0, value.translation.height)
                    }
                    .onEnded { value in
                        let shouldClose = value.translation.height > Size.sheetDismissDistance
                        withAnimation(Motion.sheet) {
                            if shouldClose { isPresented = false }
                            dragOffset = 0
                        }
                    }
            )
            .accessibilityHidden(true)
    }
}

extension View {
    /// Показывает тёмную стеклянную шторку поверх экрана.
    func glassSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> SheetContent
    ) -> some View {
        modifier(GlassSheetModifier(isPresented: isPresented, sheet: content()))
    }
}

private struct GlassSheetDemo: View {
    @State private var isPresented = true

    var body: some View {
        Button("Показать шторку") { isPresented = true }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColor.background)
            .glassSheet(isPresented: $isPresented) {
                VStack {
                    Text("Новое измерение")
                        .textStyle(.title)
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                }
                .padding(Spacing.screenMargin)
            }
    }
}

#Preview("GlassSheet") {
    GlassSheetDemo()
}
