import CoreText
import UIKit
import SwiftUI

/// Шрифт SB Sans Display из `Resources/Fonts/sb-sans-display.otf` (по макету). Файл один (Regular), жирность не синтезируется.
/// Регистрируется в процессе при первом обращении (`HealthMonitorApp.init` обращается явно); имя гарнитуры берётся из
/// дескриптора файла, а не из жёстко заданной строки. Нет файла или регистрация не удалась: `name == nil`,
/// текст остаётся на системном шрифте.
enum AppFont {
    static let resource = "sb-sans-display"
    static let fileExtension = "otf"

    /// Имя гарнитуры для `Font.custom`. `nil`: шрифт не зарегистрирован.
    static let name: String? = register(bundle: .main)

    static func register(bundle: Bundle) -> String? {
        guard let url = bundle.url(forResource: resource, withExtension: fileExtension) else { return nil }
        let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor]
        guard let descriptor = descriptors?.first,
              let postScriptName = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as? String
        else { return nil }
        var error: Unmanaged<CFError>?
        let registered = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        // Повторная регистрация (уже зарегистрирован) возвращает ошибку, но шрифт доступен.
        let isAvailable = registered || UIFont(name: postScriptName, size: 12) != nil
        return isAvailable ? postScriptName : nil
    }
}
