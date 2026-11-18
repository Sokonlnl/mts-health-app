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
    /// Нижний запас прокрутки: последняя карточка поднимается выше плавающей навигации и затухающего низа.
    static let tabBarClearance: CGFloat = 240
    /// Нижний запас прокрутки главного экрана: кнопка ГигаЧата поднимается выше плавающей навигации (64 + отступ + затухание).
    static let homeBottomClearance: CGFloat = 128
    /// Зазор между малыми карточками главного экрана.
    static let tileGap: CGFloat = 9
    /// Зазор между блоками колонки главного экрана.
    static let columnGap: CGFloat = 13
    /// Зазор между заголовком-выводом и пояснением.
    static let headlineGap: CGFloat = 13
    /// Горизонтальный отступ карточки совета и кнопки ГигаЧата внутри колонки (358 → 332 и 330).
    static let adviceInset: CGFloat = 13
    /// Внутренний отступ стандартной карточки.
    static let cardPadding: CGFloat = 18
    /// Вертикальный отступ карточки-списка (у строк свои отступы).
    static let cardListVertical: CGFloat = 6
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
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: 80, alignment: .leading)
                Rectangle().fill(AppColor.textSecondary).frame(width: item.1, height: item.1)
            }
        }
    }
    .padding(Spacing.screenMargin)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColor.background)
}
