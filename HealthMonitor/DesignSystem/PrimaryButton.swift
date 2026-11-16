import SwiftUI

/// Главная кнопка (акцентная). Выключенная выглядит нейтрально.
struct PrimaryButton: View {
    let title: String
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(.bodyStrong)
                .foregroundStyle(isEnabled ? AppColor.surface : AppColor.textTertiary)
                .frame(maxWidth: .infinity, minHeight: Size.primaryButton)
                .background(
                    isEnabled ? AppColor.accent : AppColor.fill,
                    in: RoundedRectangle(cornerRadius: Radius.controlLarge, style: .continuous)
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview("PrimaryButton: включена") {
    PrimaryButton(title: "Сохранить", action: {})
        .padding(Spacing.screenMargin)
}

#Preview("PrimaryButton: выключена") {
    PrimaryButton(title: "Сохранить", isEnabled: false, action: {})
        .padding(Spacing.screenMargin)
}
