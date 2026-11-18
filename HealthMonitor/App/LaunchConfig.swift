import Foundation

/// Конфигурация запуска из аргументов: `-uiScreen home|pressure|pressureSheet|loading|empty|error`.
/// Нужна для UI-тестов и демонстрации состояний.
struct LaunchConfig: Equatable {
    enum Screen: String {
        case home
        case pressure
        case pressureSheet
        case loading
        case empty
        case error
    }

    static let argumentName = "-uiScreen"
    /// Отключает заставку главного (UI-тесты не ждут анимацию).
    static let disableIntroArgument = "-uiTestsDisableIntro"

    let screen: Screen
    var disablesIntro = false

    static var current: LaunchConfig {
        parse(ProcessInfo.processInfo.arguments)
    }

    static func parse(_ arguments: [String]) -> LaunchConfig {
        let disablesIntro = arguments.contains(disableIntroArgument)
        guard let index = arguments.firstIndex(of: argumentName),
              arguments.indices.contains(index + 1),
              let screen = Screen(rawValue: arguments[index + 1])
        else {
            return LaunchConfig(screen: .home, disablesIntro: disablesIntro)
        }
        return LaunchConfig(screen: screen, disablesIntro: disablesIntro)
    }

    var scenario: MockScenario {
        switch screen {
        case .loading: return .neverLoads
        case .empty: return .empty
        case .error: return .failure
        case .home, .pressure, .pressureSheet: return .normal
        }
    }

    var initialPath: [AppRoute] {
        switch screen {
        case .pressure, .pressureSheet: return [.pressure]
        default: return []
        }
    }

    var opensSheet: Bool { screen == .pressureSheet }
}
