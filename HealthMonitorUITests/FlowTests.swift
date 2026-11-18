import XCTest

/// Сценарные UI-тесты: смена периода, ввод в шторке, сохранение, разворот вывода.
/// Скриншотные тесты остаются в `ScreenshotTests`.
final class FlowTests: XCTestCase {
    private let timeout: TimeInterval = 15

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Помощники

    private func launch(_ screen: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-uiScreen", screen, LaunchConfig.disableIntroArgument]
        app.launch()
        return app
    }

    private func element(_ app: XCUIApplication, _ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func tap(_ app: XCUIApplication, _ identifier: String, file: StaticString = #filePath, line: UInt = #line) {
        let target = element(app, identifier)
        XCTAssertTrue(target.waitForExistence(timeout: timeout), "Нет элемента \(identifier)", file: file, line: line)
        target.tap()
    }

    private func type(_ app: XCUIApplication, digits: String) {
        for digit in digits {
            tap(app, "key-\(digit)")
        }
    }

    private func openSheet() -> XCUIApplication {
        let app = launch("pressureSheet")
        XCTAssertTrue(element(app, "sheet-title").waitForExistence(timeout: timeout))
        XCTAssertTrue(element(app, "save-button").waitForExistence(timeout: timeout))
        return app
    }

    // MARK: - Период

    func testPeriodSwitchOnPressureScreen() {
        let app = launch("pressure")
        XCTAssertTrue(element(app, "pressure-latest-value").waitForExistence(timeout: timeout))

        let week = element(app, "period-Неделя")
        let month = element(app, "period-Месяц")
        XCTAssertTrue(week.waitForExistence(timeout: timeout))
        XCTAssertTrue(month.waitForExistence(timeout: timeout))
        XCTAssertTrue(week.isSelected, "По умолчанию выбрана «Неделя»")

        month.tap()
        XCTAssertTrue(month.isSelected)
        XCTAssertFalse(week.isSelected)
        XCTAssertTrue(element(app, "pressure-chart").waitForExistence(timeout: timeout))

        week.tap()
        XCTAssertTrue(week.isSelected)
        XCTAssertFalse(month.isSelected)
        XCTAssertTrue(element(app, "pressure-chart").waitForExistence(timeout: timeout))
    }

    // MARK: - Шторка

    func testSavingValidMeasurementClosesSheet() {
        let app = openSheet()
        let save = element(app, "save-button")
        XCTAssertFalse(save.isEnabled, "Пустая форма: «Сохранить» неактивна")

        type(app, digits: "130")   // верхнее, фокус уходит на нижнее
        type(app, digits: "85")
        XCTAssertTrue(element(app, "sheet-result").waitForExistence(timeout: timeout), "Появилась зона результата")

        tap(app, "chip-Утро")
        XCTAssertTrue(save.isEnabled, "130/85: «Сохранить» активна")

        save.tap()
        XCTAssertTrue(element(app, "sheet-title").waitForNonExistence(timeout: timeout), "Шторка закрылась")
        XCTAssertTrue(element(app, "pressure-latest-value").waitForExistence(timeout: timeout))
    }

    func testInvalidInputKeepsSaveDisabled() {
        let app = openSheet()
        type(app, digits: "300")
        type(app, digits: "80")

        XCTAssertTrue(element(app, "sheet-hint").waitForExistence(timeout: timeout), "Показана подсказка об ошибке")
        XCTAssertFalse(element(app, "save-button").isEnabled, "300/80: «Сохранить» неактивна")
        XCTAssertFalse(element(app, "sheet-result").exists)
    }

    func testSystolicNotAboveDiastolicKeepsSaveDisabled() {
        let app = openSheet()
        type(app, digits: "120")
        type(app, digits: "130")

        XCTAssertTrue(element(app, "sheet-hint").waitForExistence(timeout: timeout))
        XCTAssertFalse(element(app, "save-button").isEnabled)
    }

    // MARK: - Главный экран

    func testAnalysesTabShowsComingSoon() {
        let app = launch("home")
        XCTAssertFalse(element(app, "soon-toast").exists)
        tap(app, "tab-analyses")
        XCTAssertTrue(element(app, "soon-toast").waitForExistence(timeout: timeout), "Заглушка «Анализы»: сообщение «Скоро»")
    }

    func testGigaChatButtonShowsComingSoon() {
        let app = launch("home")
        let button = element(app, "gigachat-button")
        XCTAssertTrue(button.waitForExistence(timeout: timeout))
        for _ in 0..<6 where !button.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(button.isHittable, "Кнопка ГигаЧата доступна в конце прокрутки, не под навигацией")
        button.tap()
        XCTAssertTrue(element(app, "soon-toast").waitForExistence(timeout: timeout))
    }

    func testInsightDetailsExpandAndCollapse() {
        let app = launch("home")
        let toggle = element(app, "insight-toggle")
        XCTAssertTrue(toggle.waitForExistence(timeout: timeout))
        XCTAssertFalse(element(app, "insight-details").exists, "Свёрнуто по умолчанию")

        toggle.tap()
        XCTAssertTrue(element(app, "insight-details").waitForExistence(timeout: timeout), "«Подробнее» разворачивает вывод")

        toggle.tap()
        XCTAssertTrue(element(app, "insight-details").waitForNonExistence(timeout: timeout), "«Свернуть» скрывает вывод")
    }
}
