/// Launch-аргументы приложения. UI-тесты не видят типы приложения (нет `@testable import`), поэтому строки заданы здесь.
enum UITestArgs {
    static let screen = "-uiScreen"
    static let disableIntro = "-uiTestsDisableIntro"
}
