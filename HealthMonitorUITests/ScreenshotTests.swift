import XCTest

final class ScreenshotTests: XCTestCase {
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

    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Скриншоты состояний

    func testHomeScreenshot() {
        let app = launch("home")
        XCTAssertTrue(element(app, "pressure-card").waitForExistence(timeout: timeout))
        attachScreenshot(app, name: "01-home")
    }

    func testPressureScreenshot() {
        let app = launch("pressure")
        XCTAssertTrue(element(app, "pressure-latest-value").waitForExistence(timeout: timeout))
        XCTAssertTrue(element(app, "pressure-chart").waitForExistence(timeout: timeout))
        attachScreenshot(app, name: "02-pressure")
    }

    func testHomeScrolledScreenshot() {
        let app = launch("home")
        XCTAssertTrue(element(app, "pressure-card").waitForExistence(timeout: timeout))
        app.swipeUp()
        app.swipeUp()
        attachScreenshot(app, name: "01-home-scrolled")
    }

    func testPressureScrolledScreenshot() {
        let app = launch("pressure")
        XCTAssertTrue(element(app, "pressure-chart").waitForExistence(timeout: timeout))
        app.swipeUp()
        app.swipeUp()
        attachScreenshot(app, name: "02-pressure-scrolled")
    }

    func testPressureSheetScreenshot() {
        let app = launch("pressureSheet")
        XCTAssertTrue(element(app, "sheet-title").waitForExistence(timeout: timeout))
        XCTAssertTrue(element(app, "save-button").waitForExistence(timeout: timeout))
        attachScreenshot(app, name: "03-pressure-sheet")
    }

    func testLoadingScreenshot() {
        let app = launch("loading")
        XCTAssertTrue(element(app, "loading-state").waitForExistence(timeout: timeout))
        attachScreenshot(app, name: "04-loading")
    }

    func testEmptyScreenshot() {
        let app = launch("empty")
        XCTAssertTrue(element(app, "empty-state").waitForExistence(timeout: timeout))
        attachScreenshot(app, name: "05-empty")
    }

    func testErrorScreenshot() {
        let app = launch("error")
        XCTAssertTrue(element(app, "error-state").waitForExistence(timeout: timeout))
        XCTAssertTrue(element(app, "error-state-action").waitForExistence(timeout: timeout))
        attachScreenshot(app, name: "06-error")
    }

    // MARK: - Сценарий

    func testNavigationFlowOpensPressureAndSheet() {
        let app = launch("home")

        // Нажатие на плитку давления открывает экран давления.
        let card = element(app, "pressure-card")
        XCTAssertTrue(card.waitForExistence(timeout: timeout))
        card.tap()
        XCTAssertTrue(element(app, "pressure-title").waitForExistence(timeout: timeout))

        // Назад на главный: карточка давления на месте.
        let back = element(app, "back-button")
        XCTAssertTrue(back.waitForExistence(timeout: timeout))
        back.tap()
        XCTAssertTrue(card.waitForExistence(timeout: timeout), "Главный экран: карточка давления")

        // Повторное нажатие снова открывает экран давления.
        card.tap()
        XCTAssertTrue(element(app, "pressure-title").waitForExistence(timeout: timeout))

        // «+» на экране давления открывает шторку.
        let sheetButton = element(app, "pressure-add-button")
        XCTAssertTrue(sheetButton.waitForExistence(timeout: timeout))
        sheetButton.tap()
        XCTAssertTrue(element(app, "sheet-title").waitForExistence(timeout: timeout))
    }
}
