import SnapshotTesting
import SwiftUI
import XCTest
@testable import HealthMonitor

/// Визуальная регрессия по пикселям: каждый экран и состояние сравнивается с эталоном
/// в `HealthMonitorTests/__Snapshots__/SnapshotTests/`.
///
/// Детерминизм: фиксированное «сейчас», мок без задержки, данные загружены до рендера,
/// фоновое движение формы Aura выключено (`isAmbientMotionEnabled`).
///
/// Эталоны: если файла нет, библиотека записывает его и роняет тест (режим `.missing`).
/// CI выкладывает записанные файлы артефактом `snapshots`; их коммитят после просмотра.
/// Чтобы перезаписать эталон после намеренного изменения дизайна, удалите PNG и запустите CI.
@MainActor
final class SnapshotTests: XCTestCase {
    /// Допуск на сглаживание и мелкие отличия версий симулятора.
    private let precision: Float = 0.99
    private let perceptualPrecision: Float = 0.98

    private func makeStore(_ scenario: MockScenario) -> HealthStore {
        HealthStore(
            repository: MockHealthRepository(scenario: scenario, now: TestClock.now, delayNanoseconds: 0),
            clock: { TestClock.now }
        )
    }

    private func loadedStore(_ scenario: MockScenario) async -> HealthStore {
        let store = makeStore(scenario)
        await store.loadIfNeeded()
        return store
    }

    private func assertScreen<V: View>(
        _ view: V,
        named name: String,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        let root = view
            .environment(\.isAmbientMotionEnabled, false)
            .environment(\.colorScheme, .dark)
            .preferredColorScheme(.dark)
        let controller = UIHostingController(rootView: root)
        controller.overrideUserInterfaceStyle = .dark
        assertSnapshot(
            of: controller,
            as: .image(
                on: .iPhone13(.portrait),
                precision: precision,
                perceptualPrecision: perceptualPrecision,
                traits: UITraitCollection(userInterfaceStyle: .dark)
            ),
            named: name,
            file: file,
            testName: testName,
            line: line
        )
    }

    private func home(_ store: HealthStore) -> some View {
        HomeView(viewModel: HomeViewModel(store: store, now: { TestClock.now }), onOpenPressure: {})
    }

    private func pressure(_ viewModel: PressureViewModel) -> some View {
        NavigationStack { PressureView(viewModel: viewModel) }
    }

    // MARK: - Главный экран

    func testHomeContent() async {
        assertScreen(home(await loadedStore(.normal)), named: "home-content")
    }

    func testHomeLoading() {
        assertScreen(home(makeStore(.neverLoads)), named: "home-loading")
    }

    func testHomeEmpty() async {
        assertScreen(home(await loadedStore(.empty)), named: "home-empty")
    }

    func testHomeError() async {
        assertScreen(home(await loadedStore(.failure)), named: "home-error")
    }

    // MARK: - Экран давления

    func testPressureContent() async {
        let viewModel = PressureViewModel(store: await loadedStore(.normal), now: { TestClock.now })
        assertScreen(pressure(viewModel), named: "pressure-content")
    }

    func testPressureMonthPeriod() async {
        let viewModel = PressureViewModel(store: await loadedStore(.normal), now: { TestClock.now })
        viewModel.period = .month
        assertScreen(pressure(viewModel), named: "pressure-month")
    }

    func testPressureLoading() {
        let viewModel = PressureViewModel(store: makeStore(.neverLoads), now: { TestClock.now })
        assertScreen(pressure(viewModel), named: "pressure-loading")
    }

    func testPressureEmpty() async {
        let viewModel = PressureViewModel(store: await loadedStore(.empty), now: { TestClock.now })
        assertScreen(pressure(viewModel), named: "pressure-empty")
    }

    func testPressureError() async {
        let viewModel = PressureViewModel(store: await loadedStore(.failure), now: { TestClock.now })
        assertScreen(pressure(viewModel), named: "pressure-error")
    }

    func testPressureSheetFilled() async {
        let viewModel = PressureViewModel(store: await loadedStore(.normal), now: { TestClock.now })
        viewModel.draft.systolicText = "132"
        viewModel.draft.diastolicText = "86"
        viewModel.draft.pulseText = "70"
        viewModel.isSheetPresented = true
        assertScreen(pressure(viewModel), named: "pressure-sheet")
    }
}
