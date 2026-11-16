import SwiftUI

/// Заголовок секции или карточки (headline). Читается VoiceOver как заголовок.
struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .textStyle(.headline)
            .foregroundStyle(AppColor.textPrimary)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview("SectionHeader") {
    SectionHeader(title: "Показатели")
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
