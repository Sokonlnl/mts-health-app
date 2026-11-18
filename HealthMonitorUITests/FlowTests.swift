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
        app.launchArguments += [UITestArgs.screen, screen, UITestArgs.disableIntro]
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

    // MARK: - Главный экран

    func testAnalysesTabShowsPlaceholderOnTapAndSwipe() {
        let app = launch("home")
        XCTAssertTrue(element(app, "tab-wellbeing").waitForExistence(timeout: timeout))
        XCTAssertTrue(element(app, "tab-wellbeing").isSelected, "Открыта вкладка «Самочувствие»")
        tap(app, "tab-analyses")
        XCTAssertTrue(element(app, "analyses-placeholder").waitForExistence(timeout: timeout), "Вкладка «Анализы»: «Ещё в прогрессе»")
        XCTAssertFalse(element(app, "soon-toast").exists, "Без сообщения «Скоро»")
        tap(app, "tab-wellbeing")
        XCTAssertTrue(element(app, "pressure-card").waitForExistence(timeout: timeout))
        app.swipeLeft()
        XCTAssertTrue(element(app, "analyses-placeholder").waitForExistence(timeout: timeout), "Свайп влево открывает «Анализы»")
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
