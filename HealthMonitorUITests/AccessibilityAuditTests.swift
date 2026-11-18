import XCTest

/// Автоматический аудит доступности (iOS 17 `performAccessibilityAudit`) на каждом экране и состоянии:
/// контраст, размер целей нажатия, подписи VoiceOver, Dynamic Type, обрезка текста, трейты.
///
/// Каждая найденная проблема роняет тест, если для неё нет записи в `AccessibilityWaivers` с причиной.
/// Полный отчёт по экрану прикладывается вложением `a11y-<экран>` (артефакт `screenshots` в CI).
final class AccessibilityAuditTests: XCTestCase {
    private let timeout: TimeInterval = 15

    /// Исключения живут в защищённом файле `AccessibilityWaivers.swift`.
    private let waivers = AccessibilityWaivers.all

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    /// Исключение без причины недопустимо: иначе список `waivers` становится тихим выключателем аудита.
    func testEveryWaiverHasReason() {
        for waiver in waivers {
            XCTAssertFalse(
                waiver.reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                "Исключение \(waiver.type.rawValue) / \(waiver.identifier ?? "любой элемент") без причины"
            )
        }
    }

    // MARK: - Экраны

    func testHomeAudit() throws {
        try audit(screen: "home", readyIdentifier: "pressure-card")
    }

    func testPressureAudit() throws {
        try audit(screen: "pressure", readyIdentifier: "pressure-chart")
    }

    func testLoadingAudit() throws {
        try audit(screen: "loading", readyIdentifier: "loading-state")
    }

    func testEmptyAudit() throws {
        try audit(screen: "empty", readyIdentifier: "empty-state")
    }

    func testErrorAudit() throws {
        try audit(screen: "error", readyIdentifier: "error-state-action")
    }

    // MARK: - Аудит

    private func audit(screen: String, readyIdentifier: String) throws {
        let app = XCUIApplication()
        app.launchArguments += [UITestArgs.screen, screen, UITestArgs.disableIntro]
        app.launch()
        let ready = app.descendants(matching: .any).matching(identifier: readyIdentifier).firstMatch
        XCTAssertTrue(ready.waitForExistence(timeout: timeout), "Экран \(screen) не загрузился")

        var report: [String] = []
        defer {
            let text = report.isEmpty ? "Проблем не найдено." : report.joined(separator: "\n")
            let attachment = XCTAttachment(string: text)
            attachment.name = "a11y-\(screen)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }

        try app.performAccessibilityAudit(for: .all) { issue in
            let identifier = issue.element?.identifier ?? ""
            let label = issue.element?.label ?? ""
            let line = "\(Self.name(of: issue.auditType)) | id=\(identifier) | label=\(label) | \(issue.compactDescription)"
            if let waiver = self.waivers.first(where: {
                $0.type == issue.auditType && ($0.identifier == nil || $0.identifier == identifier)
            }) {
                report.append("WAIVED: \(line) | причина: \(waiver.reason)")
                return true
            }
            report.append("FAIL: \(line)")
            return false
        }
    }

    private static func name(of type: XCUIAccessibilityAuditType) -> String {
        switch type {
        case .contrast: return "contrast"
        case .elementDetection: return "elementDetection"
        case .hitRegion: return "hitRegion"
        case .sufficientElementDescription: return "sufficientElementDescription"
        case .dynamicType: return "dynamicType"
        case .textClipped: return "textClipped"
        case .trait: return "trait"
        default: return "other(\(type.rawValue))"
        }
    }
}
