import XCTest
@testable import HealthMonitor

@MainActor
final class HomeTilesTests: XCTestCase {
    private func makeViewModel(pressure: [PressureMeasurement], data: HealthData? = nil) async -> HomeViewModel {
        var healthData = data ?? TestData.healthData(pressure: pressure)
        healthData.pressure = pressure
        let store = HealthStore(repository: StubRepository(data: healthData))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        await viewModel.load()
        return viewModel
    }

    // MARK: - Карточки

    func testPressureCardShowsLatestValueAndZone() async {
        let viewModel = await makeViewModel(
            pressure: [TestData.measurement("a", systolic: 122, diastolic: 79, secondsAgo: 0)]
        )
        let card = viewModel.pressureCard
        XCTAssertEqual(card.valueText, "122/79")
        XCTAssertEqual(card.statusText, PressureZone.normal.title)
        XCTAssertEqual(card.tone, .positive)
        XCTAssertNil(card.gauge, "У давления мини-шкалы нет")
        XCTAssertEqual(viewModel.glowState, .normal)
    }

    func testEmptyPressureCardHasPlaceholderAndNoDataStatus() async {
        let viewModel = await makeViewModel(pressure: [])
        let card = viewModel.pressureCard
        XCTAssertNil(card.valueText)
        XCTAssertTrue(card.isPlaceholder)
        XCTAssertEqual(card.displayValue, AppFormat.emptyPressureValue)
        XCTAssertEqual(card.statusText, AppFormat.noData)
        XCTAssertEqual(card.unit, AppUnit.pressure)
        XCTAssertEqual(viewModel.glowState, .noData)
    }

    func testElevatedAndHighPressureChangeGlowStateAndTone() async {
        let elevated = await makeViewModel(pressure: [TestData.measurement("a", systolic: 134, diastolic: 86, secondsAgo: 0)])
        XCTAssertEqual(elevated.glowState, .elevated)
        XCTAssertEqual(elevated.pressureCard.statusText, PressureZone.elevated.title)
        XCTAssertEqual(elevated.pressureCard.tone, .caution)
        let high = await makeViewModel(pressure: [TestData.measurement("b", systolic: 148, diastolic: 94, secondsAgo: 0)])
        XCTAssertEqual(high.glowState, .high)
        XCTAssertEqual(high.pressureCard.tone, .critical)
    }

    func testSmallCardsAreWeightAndGlucoseWithGaugesAndNoStatus() async {
        var data = TestData.healthData(pressure: [])
        data.weight = MetricReading(latest: 75)
        data.glucose = MetricReading(latest: 6)
        let viewModel = await makeViewModel(pressure: [], data: data)
        XCTAssertEqual(viewModel.smallCards.map(\.kind), [.weight, .glucose])
        XCTAssertEqual(viewModel.smallCards.map(\.valueText), ["75,0", "6,0"])
        XCTAssertEqual(viewModel.smallCards.map(\.unit), [AppUnit.weight, AppUnit.glucose])
        XCTAssertEqual(viewModel.smallCards.map(\.gauge), [.bands, .arc])
        XCTAssertTrue(viewModel.smallCards.allSatisfy { $0.statusText == nil })
        XCTAssertEqual(viewModel.weightCard.gaugePosition ?? -1, 0.5, accuracy: 0.0001)
        XCTAssertEqual(viewModel.glucoseCard.gaugePosition ?? -1, 0.5, accuracy: 0.0001)
    }

    func testEmptySmallCardsKeepPlaceholderAndCaption() async {
        let viewModel = await makeViewModel(pressure: [])
        let glucose = viewModel.glucoseCard
        XCTAssertNil(glucose.valueText)
        XCTAssertNil(glucose.gaugePosition)
        XCTAssertEqual(glucose.displayValue, AppFormat.dash)
        XCTAssertEqual(glucose.captionText, "ммоль/л · измерений пока нет")
        XCTAssertEqual(glucose.accessibilityText, "Глюкоза: нет данных")
        XCTAssertEqual(viewModel.pressureCard.captionText, AppUnit.pressure, "Со статусом подпись остаётся единицей")
    }

    func testAccessibilityTextOfFilledCards() async {
        var data = TestData.healthData(pressure: [])
        data.weight = MetricReading(latest: 72.4)
        let viewModel = await makeViewModel(
            pressure: [TestData.measurement("a", systolic: 122, diastolic: 79, secondsAgo: 0)], data: data
        )
        XCTAssertEqual(viewModel.pressureCard.accessibilityText, "Давление 122/79 мм рт. ст., норма")
        XCTAssertEqual(viewModel.weightCard.accessibilityText, "Вес 72,4 кг")
    }

    // MARK: - Вывод

    func testHeadlineFollowsZone() async {
        let normal = await makeViewModel(pressure: [TestData.measurement("a", systolic: 118, diastolic: 76, secondsAgo: 0)])
        XCTAssertEqual(normal.headline.title, "У вас отличные показатели")
        XCTAssertEqual(normal.headline.summary, "Все ваши показатели в норме")
        XCTAssertEqual(normal.headline.details, normal.insight.details)
        let elevated = await makeViewModel(pressure: [TestData.measurement("b", systolic: 134, diastolic: 86, secondsAgo: 0)])
        XCTAssertNotEqual(elevated.headline.title, normal.headline.title)
        let high = await makeViewModel(pressure: [TestData.measurement("c", systolic: 150, diastolic: 95, secondsAgo: 0)])
        XCTAssertNotEqual(high.headline.title, elevated.headline.title)
        let none = await makeViewModel(pressure: [])
        XCTAssertEqual(none.headline.title, "Пока нет данных")
    }

    func testHeadlineTextsHaveNoDiagnosisWords() {
        let states: [HealthState] = [.normal, .elevated, .high, .noData]
        for state in states {
            let text = HomeText.headline(for: state)
            let combined = (text.title + " " + text.summary).lowercased()
            XCTAssertFalse(combined.contains("гипертони"), "Без диагнозов: \(combined)")
            XCTAssertFalse(combined.contains("диагноз"), "Без диагнозов: \(combined)")
        }
    }

    // MARK: - Совет

    func testAdviceCardComesFromData() async {
        var data = TestData.healthData(pressure: [])
        data.advice = MockHealthData.advice
        let viewModel = await makeViewModel(pressure: [], data: data)
        let card = viewModel.adviceCard
        XCTAssertEqual(card?.title, AdviceSelector.pick(from: MockHealthData.advice, zone: nil)?.title)
        XCTAssertEqual(card?.author, "ГигаЧат")
        XCTAssertEqual(card?.role, "Медицинский помощник")
    }

    func testAdviceFollowsZoneAndAddsDisclaimerOnlyAboveNorm() async {
        var data = TestData.healthData(pressure: [])
        data.advice = MockHealthData.advice
        struct ZoneCase {
            let systolic: Int
            let diastolic: Int
            let zone: PressureZone
        }
        let cases = [
            ZoneCase(systolic: 118, diastolic: 76, zone: .normal),
            ZoneCase(systolic: 134, diastolic: 86, zone: .elevated),
            ZoneCase(systolic: 148, diastolic: 94, zone: .high)
        ]
        for item in cases {
            let zone = item.zone
            let measurement = TestData.measurement("z", systolic: item.systolic, diastolic: item.diastolic, secondsAgo: 0)
            let viewModel = await makeViewModel(pressure: [measurement], data: data)
            let expected = AdviceSelector.pick(from: MockHealthData.advice, zone: zone)
            XCTAssertEqual(viewModel.adviceCard?.title, expected?.title)
            XCTAssertEqual(viewModel.adviceCard?.disclaimer, AdviceSelector.disclaimer(for: zone))
        }
        XCTAssertNotEqual(
            AdviceSelector.pick(from: MockHealthData.advice, zone: .normal)?.id,
            AdviceSelector.pick(from: MockHealthData.advice, zone: .high)?.id
        )
    }

    func testDisclaimerDiffersByZone() {
        XCTAssertNil(AdviceSelector.disclaimer(for: .normal))
        XCTAssertNil(AdviceSelector.disclaimer(for: nil))
        XCTAssertEqual(AdviceSelector.disclaimer(for: .elevated), HomeText.adviceDisclaimerElevated)
        XCTAssertEqual(AdviceSelector.disclaimer(for: .high), HomeText.adviceDisclaimerHigh)
        XCTAssertTrue(HomeText.adviceDisclaimerHigh.contains("Повторите измерение в покое"))
        XCTAssertNotEqual(HomeText.adviceDisclaimerElevated, HomeText.adviceDisclaimerHigh)
    }

    func testIntroSkipsWaitWithoutAnimations() async {
        let store = HealthStore(repository: StubRepository(data: TestData.healthData(pressure: [])))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        var delays: [UInt64] = []
        await viewModel.runIntro(animationsEnabled: false) { delays.append($0) }
        XCTAssertTrue(delays.isEmpty)
        XCTAssertFalse(viewModel.isIntroPending)
    }

    func testIntroWaitsThenCompletesAndDoesNotReplay() async {
        let store = HealthStore(repository: StubRepository(data: TestData.healthData(pressure: [])))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        var delays: [UInt64] = []
        var pendingDuringWait = false
        await viewModel.runIntro(animationsEnabled: true) { delay in
            delays.append(delay)
            pendingDuringWait = viewModel.isIntroPending
        }
        XCTAssertEqual(delays, [Motion.introNanoseconds])
        XCTAssertTrue(pendingDuringWait)
        XCTAssertFalse(viewModel.isIntroPending)
        await viewModel.runIntro(animationsEnabled: true) { delays.append($0) }
        XCTAssertEqual(delays.count, 1, "Повторно заставка не играет")
    }

    func testPressureCardRhythmFollowsPulse() async {
        let viewModel = await makeViewModel(pressure: [])
        XCTAssertEqual(viewModel.pressureCard.rhythm?.period ?? 0, 60.0 / 68.0, accuracy: 0.0001)
    }

    func testIntroPlaysOnceAndCanBeDisabled() async {
        let store = HealthStore(repository: StubRepository(data: TestData.healthData(pressure: [])))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        XCTAssertTrue(viewModel.isIntroPending)
        viewModel.completeIntro()
        XCTAssertFalse(viewModel.isIntroPending)
        let off = HomeViewModel(store: store, now: { TestClock.now }, playsIntro: false)
        XCTAssertFalse(off.isIntroPending)
    }

    func testEmptyMessageComesFromHomeText() async {
        let viewModel = await makeViewModel(pressure: [])
        XCTAssertEqual(viewModel.emptyMessage, HomeText.emptyMessage)
    }

    func testNoAdviceWhenDataHasNone() async {
        let viewModel = await makeViewModel(pressure: [])
        XCTAssertNil(viewModel.adviceCard)
    }

    // MARK: - Заглушки

    func testAnalysesTabAndGigaChatShowComingSoon() async {
        let viewModel = await makeViewModel(pressure: [])
        XCTAssertNil(viewModel.toastMessage)
        XCTAssertEqual(viewModel.tabs.map(\.id), ["wellbeing", "analyses"])
        viewModel.selectTab(viewModel.selectedTabID)
        XCTAssertNil(viewModel.toastMessage, "Открытая вкладка сообщения не показывает")
        viewModel.selectTab(HomeViewModel.analysesTabID)
        XCTAssertEqual(viewModel.toastMessage, "Скоро будет доступно")
        viewModel.toastMessage = nil
        viewModel.showComingSoon()
        XCTAssertEqual(viewModel.toastMessage, HomeText.comingSoon)
        XCTAssertEqual(viewModel.selectedTabID, HomeViewModel.wellbeingTabID, "Вкладка «Анализы» заглушка: выбор не меняется")
    }

    // MARK: - Вид экрана

    func testLoadingLayout() {
        let store = HealthStore(repository: StubRepository(data: .empty))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(viewModel.showsInsight)
        XCTAssertEqual(viewModel.heroHeight, Size.heroHeight)
    }

    func testContentLayoutShowsInsightWithFullHero() async {
        let viewModel = await makeViewModel(pressure: [TestData.measurement("a", systolic: 120, diastolic: 80, secondsAgo: 60)])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showsInsight)
        XCTAssertEqual(viewModel.heroHeight, Size.heroHeight)
    }

    func testEmptyAndErrorLayoutHaveCompactHeroWithoutInsight() async {
        let empty = HomeViewModel(store: HealthStore(repository: StubRepository(data: .empty)), now: { TestClock.now })
        await empty.load()
        XCTAssertEqual(empty.screenState, .empty)
        XCTAssertFalse(empty.showsInsight)
        XCTAssertEqual(empty.heroHeight, Size.heroCompactHeight)

        let failing = HealthStore(repository: MockHealthRepository(scenario: .failure, delayNanoseconds: 0))
        let error = HomeViewModel(store: failing, now: { TestClock.now })
        await error.load()
        XCTAssertFalse(error.showsInsight)
        XCTAssertEqual(error.heroHeight, Size.heroCompactHeight)
    }
}
