import SwiftUI

/// Отступы из docs/DESIGN.md.
enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    /// Поля экрана.
    static let screenMargin: CGFloat = 16
    /// Минимальная цель нажатия (HIG).
    static let minTapTarget: CGFloat = 44
}

#Preview("Spacing") {
    let items: [(String, CGFloat)] = [
        ("xs", Spacing.xs), ("s", Spacing.s), ("m", Spacing.m),
        ("l", Spacing.l), ("xl", Spacing.xl), ("xxl", Spacing.xxl)
    ]
    return VStack(alignment: .leading, spacing: Spacing.s) {
        ForEach(items, id: \.0) { item in
            HStack {
                Text("\(item.0) \(Int(item.1))")
                    .textStyle(.label)
                    .frame(width: 80, alignment: .leading)
                Rectangle().fill(AppColor.accent).frame(width: item.1, height: item.1)
            }
        }
    }
    .padding(Spacing.screenMargin)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColor.background)
}
