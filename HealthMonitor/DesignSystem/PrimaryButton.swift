import SwiftUI

/// Главная кнопка «Сохранить» и действия в сообщениях состояний (primaryFill, высота 56). Выключенная выглядит нейтрально.
/// Текст переносится на две строки при крупном шрифте.
struct PrimaryButton: View {
    let title: String
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(.bodyStrong)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, Spacing.xs)
                .minimumScaleFactor(TextScale.compact)
                .foregroundStyle(isEnabled ? AppColor.primaryText : AppColor.textTertiary)
                .frame(maxWidth: .infinity, minHeight: Size.primaryButton)
                .background { Capsule().fill(isEnabled ? AppColor.primaryFill : AppColor.fill) }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview("PrimaryButton: включена") {
    PrimaryButton(title: "Сохранить", action: {})
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}

#Preview("PrimaryButton: выключена") {
    PrimaryButton(title: "Сохранить", isEnabled: false, action: {})
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
