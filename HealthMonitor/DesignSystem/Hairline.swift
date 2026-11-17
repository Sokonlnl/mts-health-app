import SwiftUI

/// Тонкий разделитель цвета hairline (белый 8%). Скрыт от VoiceOver.
struct Hairline: View {
    /// Для вертикального разделителя задаётся длина.
    var verticalLength: CGFloat?

    var body: some View {
        Rectangle()
            .fill(AppColor.hairline)
            .frame(
                width: verticalLength == nil ? nil : Size.hairline,
                height: verticalLength ?? Size.hairline
            )
            .accessibilityHidden(true)
    }
}

#Preview("Hairline") {
    VStack(spacing: Spacing.l) {
        Hairline()
        HStack {
            Text("Слева").textStyle(.body).foregroundStyle(AppColor.textPrimary)
            Hairline(verticalLength: Size.navItem)
            Text("Справа").textStyle(.body).foregroundStyle(AppColor.textPrimary)
        }
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
