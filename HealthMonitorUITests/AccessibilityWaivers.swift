import XCTest

/// Осознанные исключения аудита доступности (`AccessibilityAuditTests`).
///
/// Файл защищён: менять его может только человек, отдельным коммитом (правило «изменение не меняет
/// свои проверки», CLAUDE.md). Иначе агент мог бы «починить» аудит, добавив исключение для своей же ошибки.
/// Каждое исключение обязано иметь причину. Пустой список означает «без поблажек».
struct AccessibilityWaiver {
    let type: XCUIAccessibilityAuditType
    /// accessibilityIdentifier элемента; nil означает «любой элемент этого типа на экране».
    let identifier: String?
    let reason: String
}

enum AccessibilityWaivers {
    static let all: [AccessibilityWaiver] = []
}
