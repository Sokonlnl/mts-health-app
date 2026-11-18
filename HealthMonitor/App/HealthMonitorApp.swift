import SwiftUI

@main
struct HealthMonitorApp: App {
    @State private var home: HomeViewModel
    @State private var pressure: PressureViewModel
    private let config: LaunchConfig

    init() {
        let config = LaunchConfig.current
        let store = HealthStore(repository: MockHealthRepository(scenario: config.scenario))
        let pressure = PressureViewModel(store: store)
        pressure.opensSheetOnAppear = config.opensSheet
        self.config = config
        _home = State(initialValue: HomeViewModel(store: store, playsIntro: !config.disablesIntro))
        _pressure = State(initialValue: pressure)
    }

    var body: some Scene {
        WindowGroup {
            RootView(home: home, pressure: pressure, initialPath: config.initialPath)
                .preferredColorScheme(.dark)
        }
    }
}
