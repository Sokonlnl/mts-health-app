import SwiftUI

/// Тонкий разделитель цвета border. Скрыт от VoiceOver.
struct Hairline: View {
    /// Для вертикального разделителя задаётся длина.
    var verticalLength: CGFloat?

    var body: some View {
        Rectangle()
            .fill(AppColor.border)
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
            Text("Слева").textStyle(.body)
            Hairline(verticalLength: Size.dayCircle)
            Text("Справа").textStyle(.body)
        }
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.surface)
}
