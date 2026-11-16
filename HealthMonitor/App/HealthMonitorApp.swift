import SwiftUI

@main
struct HealthMonitorApp: App {
    var body: some Scene {
        WindowGroup {
            PlaceholderView()
        }
    }
}

/// Временный экран, пока нет главного. Будет заменён на HomeView.
private struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: Spacing.m) {
            Text("Health Monitor")
                .textStyle(.title)
                .foregroundStyle(AppColor.textPrimary)
            Text("Каркас проекта")
                .textStyle(.label)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}

#Preview {
    PlaceholderView()
}
