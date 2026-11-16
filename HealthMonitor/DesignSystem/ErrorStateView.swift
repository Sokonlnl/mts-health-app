import SwiftUI

/// Состояние ошибки: сообщение и кнопка «Повторить».
struct ErrorStateView: View {
    let message: String
    var identifier = "error-state"
    let retry: () -> Void

    var body: some View {
        StateMessageView(
            icon: "exclamationmark.triangle",
            title: "Не удалось загрузить данные",
            message: message,
            identifier: identifier,
            actionTitle: "Повторить",
            action: retry
        )
    }
}

#Preview("ErrorStateView") {
    ErrorStateView(message: "Сервис временно недоступен. Проверьте соединение и повторите попытку.", retry: {})
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
