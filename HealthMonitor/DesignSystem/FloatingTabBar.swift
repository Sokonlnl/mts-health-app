import SwiftUI

enum AppTab: String, CaseIterable {
    case home
    case journal
    case profile

    var title: String {
        switch self {
        case .home: return "Главная"
        case .journal: return "Журнал"
        case .profile: return "Профиль"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .journal: return "book.fill"
        case .profile: return "person.fill"
        }
    }
}

/// Плавающая нижняя навигация-таблетка.
struct FloatingTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                item(tab)
            }
        }
        .padding(Spacing.xs)
        .background(AppColor.surface, in: Capsule())
        .cardShadow()
    }

    private func item(_ tab: AppTab) -> some View {
        let isSelected = tab == selection
        return Button {
            selection = tab
        } label: {
            VStack(spacing: Spacing.xs) {
                Image(systemName: tab.iconName)
                    .font(AppTextStyle.bodyStrong.font)
                    .accessibilityHidden(true)
                Text(tab.title)
                    .textStyle(.caption)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? AppColor.accent : AppColor.textSecondary)
            .frame(maxWidth: .infinity, minHeight: Size.tabBarItem)
            .background(isSelected ? AppColor.accentSoft : Color.clear, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("tab-\(tab.rawValue)")
    }
}

private struct FloatingTabBarDemo: View {
    @State private var selection = AppTab.home

    var body: some View {
        FloatingTabBar(selection: $selection)
            .padding(Spacing.screenMargin)
            .background(AppColor.background)
    }
}

#Preview("FloatingTabBar") {
    FloatingTabBarDemo()
}
