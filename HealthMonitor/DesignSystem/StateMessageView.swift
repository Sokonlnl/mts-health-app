import SwiftUI

/// Сообщение для empty и error состояний в стеклянной карточке, с необязательной кнопкой.
struct StateMessageView: View {
    let icon: String
    let title: String
    let message: String
    var identifier = "state-message"
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: icon)
                .textStyle(.metricCard)
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: Size.stateIcon, height: Size.stateIcon)
                .accessibilityHidden(true)
            Text(title)
                .textStyle(.headline)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(identifier)
            Text(message)
                .textStyle(.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, action: action)
                    .accessibilityIdentifier("\(identifier)-action")
            }
        }
        .glassCard(insets: CardInsets.message)
    }
}

#Preview("StateMessageView: empty") {
    StateMessageView(
        icon: "heart.text.square",
        title: "Пока нет измерений",
        message: "Добавьте первое измерение давления.",
        actionTitle: "Добавить измерение",
        action: {}
    )
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("StateMessageView: error") {
    StateMessageView(
        icon: "exclamationmark.triangle",
        title: "Не удалось загрузить данные",
        message: "Проверьте соединение и повторите попытку.",
        actionTitle: "Повторить",
        action: {}
    )
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
