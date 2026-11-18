import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    /// Идентификаторы вкладок верхнего блока: «Самочувствие» открыта, «Анализы» заглушка.
    static let wellbeingTabID = "wellbeing"
    static let analysesTabID = "analyses"

    let store: HealthStore
    @ObservationIgnored let now: () -> Date
    /// Играть ли заставку при первом показе (`-uiTestsDisableIntro` выключает её).
    @ObservationIgnored let playsIntro: Bool

    var isInsightExpanded = false
    /// Подсказка-заглушка «Скоро будет доступно» (сбрасывается сама).
    var toastMessage: String?
    /// Заставка ещё не сыграна: она играет один раз за запуск, при возврате с экрана давления не повторяется.
    private(set) var isIntroPending: Bool

    init(store: HealthStore, now: @escaping () -> Date = { Date() }, playsIntro: Bool = true) {
        self.store = store
        self.now = now
        self.playsIntro = playsIntro
        self.isIntroPending = playsIntro
    }

    var screenState: ScreenState { store.screenState }

    var insight: WeekInsight {
        WeekInsight.make(stats: WeekOverview.stats(measurements: store.data.pressure, now: now()))
    }

    func load() async {
        await store.loadIfNeeded()
    }

    func reload() async {
        await store.load()
    }

    func toggleInsight() {
        isInsightExpanded.toggle()
    }

    /// Заставка после загрузки: при включённой анимации ждёт `Motion.introNanoseconds` (`sleep` подменяется в тестах),
    /// затем отмечает её сыгранной. Без анимации и при повторном вызове завершается сразу.
    func runIntro(
        animationsEnabled: Bool,
        sleep: (UInt64) async -> Void = { try? await Task.sleep(nanoseconds: $0) }
    ) async {
        guard isIntroPending else { return }
        if animationsEnabled { await sleep(Motion.introNanoseconds) }
        completeIntro()
    }

    /// Отмечает заставку сыгранной.
    func completeIntro() {
        isIntroPending = false
    }

    // MARK: - Заглушки

    var tabs: [HomeTab] {
        [
            HomeTab(id: Self.wellbeingTabID, title: HomeText.tabWellbeing),
            HomeTab(id: Self.analysesTabID, title: HomeText.tabAnalyses)
        ]
    }

    var selectedTabID: String { Self.wellbeingTabID }

    var selectedTab: HomeTab { HomeTab(id: Self.wellbeingTabID, title: HomeText.tabWellbeing) }

    /// Выбор вкладки: «Самочувствие» уже открыта, «Анализы» пока заглушка.
    func selectTab(_ id: String) {
        guard id != selectedTabID else { return }
        showComingSoon()
    }

    /// Кнопка «Задать вопрос ГигаЧату» и вкладка «Анализы» пока не работают: короткое сообщение.
    func showComingSoon() {
        toastMessage = HomeText.comingSoon
    }
}
