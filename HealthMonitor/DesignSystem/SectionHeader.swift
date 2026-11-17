import SwiftUI

/// Заголовок секции или карточки (headline). Читается VoiceOver как заголовок.
struct SectionHeader: View {
    let title: String
    /// Компактный вариант 17 pt для заголовков блоков на экране давления.
    var isCompact = false

    var body: some View {
        Text(title)
            .textStyle(isCompact ? .headlineCompact : .headline)
            .foregroundStyle(AppColor.textPrimary)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview("SectionHeader") {
    VStack(alignment: .leading, spacing: Spacing.m) {
        SectionHeader(title: "Показатели")
        SectionHeader(title: "История", isCompact: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
