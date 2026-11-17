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

/// Плавающая нижняя навигация: стеклянная таблетка 292×64 pt, активный пункт подсвечен белым 14%.
struct FloatingTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                item(tab)
            }
        }
        .padding(.horizontal, Spacing.xs)
        .frame(width: Size.tabBarWidth)
        .frame(minHeight: Size.navBar)
        .glassBackground(in: Capsule())
    }

    private func item(_ tab: AppTab) -> some View {
        let isSelected = tab == selection
        return Button {
            selection = tab
        } label: {
            VStack(spacing: Spacing.xs) {
                Image(systemName: tab.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Size.navIcon, height: Size.navIcon)
                    .accessibilityHidden(true)
                Text(tab.title)
                    .textStyle(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(TextScale.compact)
            }
            .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
            .frame(maxWidth: .infinity, minHeight: Size.navItem)
            .background(isSelected ? AppColor.fillSelected : Color.clear, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("tab-\(tab.rawValue)")
    }
}

private struct FloatingTabBarDemo: View {
    @State private var selection = AppTab.home

    var body: some View {
        HStack(spacing: Spacing.m) {
            FloatingTabBar(selection: $selection)
        }
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
    }
}

#Preview("FloatingTabBar") {
    FloatingTabBarDemo()
}
