import SwiftUI

/// Экран давления: шапка, форма, периоды, график, среднее и диапазон, пояснение, история, шторка.
struct PressureView: View {
    @Bindable var viewModel: PressureViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                stateContent
            }
            .padding(.horizontal, Spacing.screenMargin)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.tabBarClearance)
            .auraScreenBackdrop(palette: viewModel.latestState.palette, glowHeight: Size.glowPressureHeight)
        }
        .background(AppColor.background)
        .auraBottomBar { addBar }
        .glassSheet(isPresented: $viewModel.isSheetPresented) {
            NewMeasurementSheet(viewModel: viewModel)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
            await viewModel.presentSheetIfRequested()
        }
    }

    // MARK: - Шапка и нижняя кнопка

    private var header: some View {
        HStack {
            IconButton(systemName: "chevron.left", label: "Назад") { dismiss() }
                .accessibilityIdentifier("back-button")
            Spacer(minLength: Spacing.s)
            Text("Давление")
                .textStyle(.headlineCompact)
                .foregroundStyle(AppColor.textPrimary)
                .accessibilityIdentifier("pressure-title")
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: Spacing.s)
            IconButton(systemName: "plus", label: AppFormat.addMeasurement) {
                viewModel.openSheet()
            }
            .accessibilityIdentifier("pressure-add-button")
        }
    }

    @ViewBuilder
    private var addBar: some View {
        switch viewModel.screenState {
        case .content, .empty:
            PrimaryButton(title: AppFormat.addMeasurement, style: .glass) {
                viewModel.openSheet()
            }
            .accessibilityIdentifier("pressure-add-bottom")
        case .loading, .error:
            EmptyView()
        }
    }

    // MARK: - Состояния

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.screenState {
        case .loading:
            SkeletonOrb(diameter: Size.orbPressure)
            SkeletonList(count: 2)
        case .error(let message):
            ErrorStateView(message: message, retry: { Task { await viewModel.reload() } })
        case .empty:
            hero
            EmptyStateView(
                message: "Добавьте первое измерение, и здесь появятся график и история.",
                action: { viewModel.openSheet() }
            )
        case .content:
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        hero
        SegmentedPicker(
            options: PressurePeriod.allCases,
            selection: $viewModel.period,
            title: { $0.title },
            identifierPrefix: "period"
        )
        chartCard
        statCards
        PressureWhyCard(zone: viewModel.latest?.zone, explanation: viewModel.explanationText)
        PressureHistoryList(rows: viewModel.historyRows)
    }

    private var hero: some View {
        PressureHero(
            state: viewModel.latestState,
            valueText: viewModel.latestValueText,
            unitText: viewModel.orbUnitText,
            statusText: viewModel.latestStatusText,
            subtitle: viewModel.latestSubtitleText,
            accessibilityText: viewModel.latestAccessibilityText
        )
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "Динамика", isCompact: true)
            if viewModel.periodMeasurements.isEmpty {
                Text("За выбранный период измерений нет.")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: Size.chartEmpty)
            } else {
                PressureChartView(
                    measurements: viewModel.periodMeasurements,
                    period: viewModel.period,
                    xDomain: viewModel.chartXDomain,
                    yDomain: viewModel.chartYDomain,
                    markerColor: viewModel.latestState.palette.markerGlow,
                    accessibilityValue: viewModel.chartAccessibilityValue
                )
                .contentSwap(viewModel.period)
            }
            PressureChartLegend()
        }
        .glassCard()
    }

    private var statCards: some View {
        HStack(alignment: .top, spacing: Spacing.m) {
            StatCard(
                title: "Среднее",
                value: viewModel.averageText,
                detail: viewModel.averageStatusText,
                detailTone: viewModel.averageZone?.tone ?? .neutral
            )
            .accessibilityIdentifier("pressure-average")
            StatCard(
                title: "Диапазон верхнего",
                value: viewModel.systolicRangeText,
                detail: viewModel.inNormText
            )
            .accessibilityIdentifier("pressure-range")
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview("Давление: данные") {
    let store = HealthStore(repository: MockHealthRepository(delayNanoseconds: 0))
    return PressureView(viewModel: PressureViewModel(store: store))
        .preferredColorScheme(.dark)
}

#Preview("Давление: loading") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .neverLoads))
    return PressureView(viewModel: PressureViewModel(store: store))
        .preferredColorScheme(.dark)
}

#Preview("Давление: empty") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .empty, delayNanoseconds: 0))
    return PressureView(viewModel: PressureViewModel(store: store))
        .preferredColorScheme(.dark)
}

#Preview("Давление: error") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .failure, delayNanoseconds: 0))
    return PressureView(viewModel: PressureViewModel(store: store))
        .preferredColorScheme(.dark)
}
