import SwiftUI

/// Цифровая клавиатура для шторки ввода.
struct NumericKeypad: View {
    let onDigit: (Int) -> Void
    let onDelete: () -> Void

    private let rows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

    private var keyShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
    }

    var body: some View {
        VStack(spacing: Spacing.s) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: Spacing.s) {
                    ForEach(row, id: \.self) { digit in
                        digitKey(digit)
                    }
                }
            }
            HStack(spacing: Spacing.s) {
                Color.clear
                    .frame(maxWidth: .infinity, minHeight: Size.keypadKey)
                    .accessibilityHidden(true)
                digitKey(0)
                deleteKey
            }
        }
    }

    private func digitKey(_ digit: Int) -> some View {
        Button {
            onDigit(digit)
        } label: {
            Text("\(digit)")
                .textStyle(.headline)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, minHeight: Size.keypadKey)
                .background(AppColor.fill, in: keyShape)
                .contentShape(keyShape)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("key-\(digit)")
    }

    private var deleteKey: some View {
        Button(action: onDelete) {
            Image(systemName: "delete.left")
                .font(AppTextStyle.headline.font)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, minHeight: Size.keypadKey)
                .background(AppColor.fill, in: keyShape)
                .contentShape(keyShape)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Удалить цифру")
        .accessibilityIdentifier("key-delete")
    }
}

#Preview("NumericKeypad") {
    NumericKeypad(onDigit: { _ in }, onDelete: {})
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
