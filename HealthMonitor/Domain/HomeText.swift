import Foundation

/// Тексты главного экрана: подписи, заглушки и вывод по зоне давления. Справочная информация, без диагнозов.
enum HomeText {
    static let tabWellbeing = "Самочувствие"
    static let tabAnalyses = "Анализы"
    static let adviceSectionTitle = "Советы\nот ГигаЧата"
    static let gigachatButton = "Задать вопрос ГигаЧату"
    static let gigachatName = "ГигаЧат"
    static let gigachatRole = "Медицинский помощник"
    static let comingSoon = "Скоро будет доступно"
    static let comingSoonHint = "Раздел пока недоступен, появится позже"
    static let openPressureHint = "Открывает экран давления"
    static let emptyMessage = "Добавьте первое измерение давления, и здесь появится сводка за неделю."
    /// Оговорки к совету (справочная информация, не диагноз): единственный источник, выбирает `AdviceSelector.disclaimer`.
    /// Общая оговорка экрана давления: `PressureZone.disclaimer`.
    static let adviceDisclaimerElevated = "Это справочная информация. При стабильно высоких значениях обратитесь к врачу."
    static let adviceDisclaimerHigh = "Повторите измерение в покое. Если значение остаётся высоким, обратитесь к врачу."

    /// Короткий вывод в верхнем блоке по зоне последнего измерения давления: заголовок и пояснение.
    static func headline(for state: HealthState) -> (title: String, summary: String) {
        switch state {
        case .normal:
            return ("У вас отличные показатели", "Все ваши показатели в норме")
        case .elevated:
            return ("Стоит понаблюдать за давлением", "Давление в зоне повышенного по справочной шкале")
        case .high:
            return ("Давление выше нормы", "Если значения повторяются, обсудите их с врачом")
        case .neutral, .noData:
            return ("Пока нет данных", "Добавьте измерение давления")
        }
    }
}
