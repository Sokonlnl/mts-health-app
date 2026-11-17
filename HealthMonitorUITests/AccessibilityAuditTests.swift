import XCTest

/// Автоматический аудит доступности (iOS 17 `performAccessibilityAudit`) на каждом экране и состоянии:
/// контраст, размер целей нажатия, подписи VoiceOver, Dynamic Type, обрезка текста, трейты.
///
/// Каждая найденная проблема роняет тест, если для неё нет записи в `waivers` с причиной.
/// Полный отчёт по экрану прикладывается вложением `a11y-<экран>` (артефакт `screenshots` в CI).
final class AccessibilityAuditTests: XCTestCase {
    private let timeout: TimeInterval = 15

    /// Осознанные исключения. Каждое с причиной; пустой список означает «без поблажек».
    private struct Waiver {
        let type: XCUIAccessibilityAuditType
        /// accessibilityIdentifier элемента; nil означает «любой элемент этого типа на экране».
        let identifier: String?
        let reason: String
    }

    private let waivers: [Waiver] = []

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    // MARK: - Экраны

    func testHomeAudit() throws {
        try audit(screen: "home", readyIdentifier: "pressure-card")
    }

    func testPressureAudit() throws {
        try audit(screen: "pressure", readyIdentifier: "pressure-chart")
    }

    func testPressureSheetAudit() throws {
        try audit(screen: "pressureSheet", readyIdentifier: "save-button")
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
        app.launchArguments += ["-uiScreen", screen]
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
