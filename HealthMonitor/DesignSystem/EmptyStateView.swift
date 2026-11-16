import SwiftUI

/// Пустое состояние: нет измерений, кнопка «Добавить измерение».
struct EmptyStateView: View {
    let message: String
    var identifier = "empty-state"
    let action: () -> Void

    var body: some View {
        StateMessageView(
            icon: "heart.text.square",
            title: "Пока нет измерений",
            message: message,
            identifier: identifier,
            actionTitle: "Добавить измерение",
            action: action
        )
    }
}

#Preview("EmptyStateView") {
    EmptyStateView(message: "Добавьте первое измерение, и здесь появятся график и история.", action: {})
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
