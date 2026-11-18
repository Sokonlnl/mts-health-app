import SwiftUI

extension DynamicTypeSize {
    /// Размер текста на `steps` ступеней крупнее (не выше самого большого).
    func stepped(by steps: Int) -> DynamicTypeSize {
        let all = DynamicTypeSize.allCases
        guard let index = all.firstIndex(of: self) else { return self }
        return all[min(all.count - 1, max(0, index + steps))]
    }
}

/// Делает текст внутри крупнее на `steps` ступеней относительно того, что выбрал пользователь в системе
/// (а не подменяет его): все стили `textStyle` внутри пересчитываются по новому размеру.
private struct LargerTextModifier: ViewModifier {
    let steps: Int
    @Environment(\.dynamicTypeSize) private var size

    func body(content: Content) -> some View {
        content.dynamicTypeSize(size.stepped(by: steps))
    }
}

extension View {
    /// Текст на экране крупнее на `steps` ступеней Dynamic Type (страницы показателей).
    func largerText(steps: Int) -> some View {
        modifier(LargerTextModifier(steps: steps))
    }
}
