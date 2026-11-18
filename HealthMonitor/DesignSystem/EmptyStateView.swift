import SwiftUI

/// Пустое состояние: измерений нет.
struct EmptyStateView: View {
    let message: String
    var identifier = "empty-state"

    var body: some View {
        StateMessageView(
            icon: "heart.text.square",
            title: "Пока нет измерений",
            message: message,
            identifier: identifier
        )
    }
}

#Preview("EmptyStateView") {
    EmptyStateView(message: "Измерений пока нет. Здесь появятся график и история.")
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
