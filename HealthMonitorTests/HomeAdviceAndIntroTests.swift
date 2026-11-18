import XCTest
@testable import HealthMonitor

/// Совет по зоне, колода и заставка главного экрана (вынесено из `HomeTilesTests` из-за лимита длины класса).
@MainActor
final class HomeAdviceAndIntroTests: XCTestCase {
    private func makeViewModel(pressure: [PressureMeasurement], data: HealthData? = nil) async -> HomeViewModel {
        var healthData = data ?? TestData.healthData(pressure: pressure)
        healthData.pressure = pressure
        let store = HealthStore(repository: StubRepository(data: healthData))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        await viewModel.load()
        return viewModel
    }

    func testAdviceCardComesFromData() async {
        var data = TestData.healthData(pressure: [])
        data.advice = MockHealthData.advice
        let viewModel = await makeViewModel(pressure: [], data: data)
        let card = viewModel.adviceCards.first
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
            XCTAssertEqual(viewModel.adviceCards.first?.title, expected?.title)
            XCTAssertEqual(viewModel.adviceCards.first?.disclaimer, AdviceSelector.disclaimer(for: zone))
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

    func testIntroPlaysOnceAndCanBeDisabled() async {
        let store = HealthStore(repository: StubRepository(data: TestData.healthData(pressure: [])))
        let viewModel = HomeViewModel(store: store, now: { TestClock.now })
        XCTAssertTrue(viewModel.isIntroPending)
        viewModel.completeIntro()
        XCTAssertFalse(viewModel.isIntroPending)
        let off = HomeViewModel(store: store, now: { TestClock.now }, playsIntro: false)
        XCTAssertFalse(off.isIntroPending)
    }

    func testNoAdviceWhenDataHasNone() async {
        let viewModel = await makeViewModel(pressure: [])
        XCTAssertNil(viewModel.adviceCards.first)
    }

    func testAdviceDeckRotatesAndWraps() async {
        var data = TestData.healthData(pressure: [])
        data.advice = MockHealthData.advice
        let viewModel = await makeViewModel(pressure: [], data: data)
        let initial = viewModel.adviceCards.map { $0.id }
        XCTAssertEqual(initial.count, MockHealthData.advice.count)
        viewModel.showNextAdvice()
        XCTAssertEqual(viewModel.adviceCards.map { $0.id }, Array(initial.dropFirst()) + [initial[0]], "Верхняя уходит в конец")
        XCTAssertEqual(viewModel.advicePositionText, HomeText.advicePosition(2, of: initial.count))
        viewModel.showPreviousAdvice()
        XCTAssertEqual(viewModel.adviceCards.map { $0.id }, initial)
        viewModel.showPreviousAdvice()
        XCTAssertEqual(viewModel.adviceCards.map { $0.id }, [initial[initial.count - 1]] + initial.dropLast(), "Назад: последняя наверх")
        for _ in initial { viewModel.showNextAdvice() }
        XCTAssertEqual(viewModel.adviceCards.map { $0.id }.count, initial.count)
    }
}
