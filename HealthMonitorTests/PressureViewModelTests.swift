import XCTest
@testable import HealthMonitor

@MainActor
final class PressureViewModelTests: XCTestCase {
    private func makeViewModel(
        pressure: [PressureMeasurement] = TestData.periodSample
    ) async -> (PressureViewModel, HealthStore) {
        let store = HealthStore(repository: StubRepository(data: TestData.healthData(pressure: pressure)))
        let viewModel = PressureViewModel(store: store, now: { TestClock.now })
        await viewModel.load()
        return (viewModel, store)
    }

    private func enter(_ viewModel: PressureViewModel, _ digits: [Int]) {
        digits.forEach { viewModel.inputDigit($0) }
    }

    // MARK: - Сохранение

    func testSaveAddsMeasurementFirstAndUpdatesLatest() async {
        let (viewModel, store) = await makeViewModel()
        let countBefore = store.data.pressure.count

        viewModel.openSheet()
        enter(viewModel, [1, 3, 0])   // верхнее, фокус уходит на нижнее
        enter(viewModel, [8, 5])      // нижнее, две цифры: фокус остаётся
        XCTAssertEqual(viewModel.draft.diastolicText, "85")
        XCTAssertTrue(viewModel.draft.isValid)

        viewModel.save()

        XCTAssertEqual(store.data.pressure.count, countBefore + 1)
        let first = store.data.pressure.first
        XCTAssertEqual(first?.systolic, 130)
        XCTAssertEqual(first?.diastolic, 85)
        XCTAssertEqual(viewModel.latest?.systolic, 130)
        XCTAssertEqual(viewModel.latestValueText, AppFormat.pressureValue(130, 85))
        XCTAssertEqual(viewModel.summary.latest?.systolic, 130)
        XCTAssertEqual(viewModel.history.first?.id, first?.id)
        XCTAssertFalse(viewModel.isSheetPresented, "После сохранения шторка закрывается")
    }

    func testSaveKeepsHistoryOrderedNewestFirst() async {
        let (viewModel, store) = await makeViewModel()
        viewModel.openSheet()
        enter(viewModel, [1, 3, 0, 8, 5])
        viewModel.save()

        let dates = store.data.pressure.map(\.date)
        XCTAssertEqual(dates, dates.sorted(by: >))
    }

    func testSaveIgnoredForInvalidDraft() async {
        let (viewModel, store) = await makeViewModel()
        let countBefore = store.data.pressure.count

        viewModel.openSheet()
        enter(viewModel, [3, 0, 0, 8, 0])   // 300/80
        XCTAssertFalse(viewModel.draft.isValid)
        viewModel.save()

        XCTAssertEqual(store.data.pressure.count, countBefore)
        XCTAssertTrue(viewModel.isSheetPresented, "При невалидном вводе шторка остаётся открытой")
    }

    func testSaveIncludesContextAndToggleClearsIt() async {
        let (viewModel, store) = await makeViewModel()
        viewModel.openSheet()
        enter(viewModel, [1, 3, 0, 8, 5])
        viewModel.toggleContext(.evening)
        XCTAssertEqual(viewModel.draft.context, .evening)
        viewModel.toggleContext(.evening)
        XCTAssertNil(viewModel.draft.context)
        viewModel.toggleContext(.morning)
        viewModel.save()
        XCTAssertEqual(store.data.pressure.first?.context, .morning)
    }

    func testStoreAddWorksOnEmptyHistory() async {
        let (viewModel, store) = await makeViewModel(pressure: [])
        store.add(TestData.measurement("n", systolic: 118, diastolic: 76, secondsAgo: 60))
        XCTAssertEqual(viewModel.latest?.id, "n")
        XCTAssertEqual(viewModel.summary.count, 1)
    }

    // MARK: - Ввод и фокус

    func testFocusMovesAfterThirdDigit() async {
        let (viewModel, _) = await makeViewModel()
        viewModel.openSheet()
        XCTAssertEqual(viewModel.focusedField, .systolic)
        enter(viewModel, [1, 3])
        XCTAssertEqual(viewModel.focusedField, .systolic, "После двух цифр фокус остаётся")
        enter(viewModel, [0])
        XCTAssertEqual(viewModel.focusedField, .diastolic, "После третьей цифры фокус уходит дальше")
        enter(viewModel, [1, 0, 0])
        XCTAssertEqual(viewModel.focusedField, .pulse)
        enter(viewModel, [7, 0, 0])
        XCTAssertEqual(viewModel.focusedField, .pulse, "У последнего поля фокус не уходит")
    }

    func testOpenSheetResetsDraftAndFocus() async {
        let (viewModel, _) = await makeViewModel()
        viewModel.openSheet()
        enter(viewModel, [1, 3, 0])
        viewModel.toggleContext(.morning)
        viewModel.isSheetPresented = false

        viewModel.openSheet()
        XCTAssertEqual(viewModel.draft.systolicText, "")
        XCTAssertNil(viewModel.draft.context)
        XCTAssertEqual(viewModel.focusedField, .systolic)
        XCTAssertTrue(viewModel.isSheetPresented)
    }

    // MARK: - Смена периода

    private func summary(_ period: PressurePeriod, _ viewModel: PressureViewModel) -> PressureSummary {
        viewModel.period = period
        return viewModel.summary
    }

    func testDefaultPeriodIsWeek() async {
        let (viewModel, _) = await makeViewModel()
        XCTAssertEqual(viewModel.period, .week)
    }

    func testPeriodDayShowsOnlyLastDay() async {
        let (viewModel, _) = await makeViewModel()
        let value = summary(.day, viewModel)
        XCTAssertEqual(value.count, 1)
        XCTAssertEqual(value.latest?.id, "a")
        XCTAssertEqual(value.systolicRange, 120...120)
        XCTAssertEqual(value.averageSystolic, 120)
        XCTAssertEqual(value.averageDiastolic, 80)
    }

    func testPeriodWeek() async {
        let (viewModel, _) = await makeViewModel()
        let value = summary(.week, viewModel)
        XCTAssertEqual(value.count, 2)
        XCTAssertEqual(value.latest?.id, "a")
        XCTAssertEqual(value.systolicRange, 120...140)
        XCTAssertEqual(value.diastolicRange, 80...90)
        XCTAssertEqual(value.averageSystolic, 130)
        XCTAssertEqual(value.averageDiastolic, 85)
    }

    func testPeriodMonth() async {
        let (viewModel, _) = await makeViewModel()
        let value = summary(.month, viewModel)
        XCTAssertEqual(value.count, 3)
        XCTAssertEqual(value.systolicRange, 100...140)
        XCTAssertEqual(value.diastolicRange, 60...90)
        XCTAssertEqual(value.averageSystolic, 120)
        XCTAssertEqual(value.averageDiastolic, 77)   // 230 / 3 = 76,67
    }

    func testPeriodSixMonths() async {
        let (viewModel, _) = await makeViewModel()
        let value = summary(.sixMonths, viewModel)
        XCTAssertEqual(value.count, 4)
        XCTAssertEqual(value.latest?.id, "a")
        XCTAssertEqual(value.systolicRange, 100...160)
        XCTAssertEqual(value.diastolicRange, 60...100)
        XCTAssertEqual(value.averageSystolic, 130)
        XCTAssertEqual(value.averageDiastolic, 83)   // 330 / 4 = 82,5, округление к большему
    }

    func testPeriodChangeUpdatesTextsButNotOverallLatest() async {
        let (viewModel, _) = await makeViewModel()
        viewModel.period = .day
        let dayRange = viewModel.rangeText
        let dayAverage = viewModel.averageText
        let dayLatest = viewModel.latestValueText

        viewModel.period = .sixMonths
        XCTAssertNotEqual(viewModel.rangeText, dayRange)
        XCTAssertNotEqual(viewModel.averageText, dayAverage)
        XCTAssertEqual(viewModel.latestValueText, dayLatest, "Крупное значение не зависит от периода")
    }

    func testPeriodWithoutDataGivesDashes() async {
        let old = [TestData.measurement("old", systolic: 120, diastolic: 80, secondsAgo: 100 * TestClock.day)]
        let (viewModel, _) = await makeViewModel(pressure: old)
        viewModel.period = .week
        XCTAssertEqual(viewModel.summary.count, 0)
        XCTAssertEqual(viewModel.rangeText, AppFormat.dash)
        XCTAssertEqual(viewModel.averageText, AppFormat.dash)
        XCTAssertTrue(viewModel.periodMeasurements.isEmpty)
    }

    // MARK: - Модели для View

    func testDraftResultToneAppearsOnlyWithZone() async {
        let (viewModel, _) = await makeViewModel()
        viewModel.openSheet()
        XCTAssertNil(viewModel.draftResultTone)
        XCTAssertEqual(viewModel.draftResultText, "Введите значения")
        enter(viewModel, [1, 3, 0, 8, 5])
        XCTAssertEqual(viewModel.draftResultTone, .caution)
        XCTAssertEqual(viewModel.draftResultText, "Будет: \(PressureZone.elevated.title)")
    }

    func testHistoryRowCarriesStatusTextAndTone() async {
        let (viewModel, _) = await makeViewModel(
            pressure: [TestData.measurement("h", systolic: 148, diastolic: 94, secondsAgo: 60)]
        )
        XCTAssertEqual(viewModel.historyRows.first?.statusText, PressureZone.high.title)
        XCTAssertEqual(viewModel.historyRows.first?.tone, .critical)
    }

    func testZonePlatesMarkCurrentZoneAndPlaceholder() async {
        let (viewModel, _) = await makeViewModel(
            pressure: [TestData.measurement("p", systolic: 134, diastolic: 86, secondsAgo: 60)]
        )
        XCTAssertEqual(viewModel.zonePlates.filter(\.isCurrent).map(\.title), [PressureZone.elevated.title])
        XCTAssertFalse(viewModel.latestIsPlaceholder)
        let (empty, _) = await makeViewModel(pressure: [])
        XCTAssertTrue(empty.latestIsPlaceholder)
        XCTAssertTrue(empty.zonePlates.allSatisfy { !$0.isCurrent })
    }
}
