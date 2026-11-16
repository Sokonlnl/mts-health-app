import SwiftUI

enum AppRoute: Hashable {
    case pressure
}

/// Корневая навигация: главный экран и экран давления.
struct RootView: View {
    let home: HomeViewModel
    let pressure: PressureViewModel
    @State private var path: [AppRoute]

    init(home: HomeViewModel, pressure: PressureViewModel, initialPath: [AppRoute] = []) {
        self.home = home
        self.pressure = pressure
        _path = State(initialValue: initialPath)
    }

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(viewModel: home, onOpenPressure: openPressure)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .pressure:
                        PressureView(viewModel: pressure)
                    }
                }
        }
    }

    private func openPressure() {
        guard path.last != .pressure else { return }
        path.append(.pressure)
    }
}
