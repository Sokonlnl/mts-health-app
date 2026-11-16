import SwiftUI

/// Экран давления.
struct PressureView: View {
    @Bindable var viewModel: PressureViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, Spacing.screenMargin)
                .padding(.vertical, Spacing.s)
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    stateContent
                }
                .padding(.horizontal, Spacing.screenMargin)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .background(AppColor.background)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.isSheetPresented) {
            NewMeasurementSheet(viewModel: viewModel)
        }
        .task {
            await viewModel.load()
            await viewModel.presentSheetIfRequested()
        }
    }

    private var header: some View {
        HStack {
            IconButton(systemName: "chevron.left", label: "Назад") { dismiss() }
                .accessibilityIdentifier("back-button")
            Spacer(minLength: Spacing.s)
            Text("Давление")
                .textStyle(.headline)
                .foregroundStyle(AppColor.textPrimary)
                .accessibilityIdentifier("pressure-title")
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: Spacing.s)
            IconButton(systemName: "plus", label: "Добавить измерение", style: .accent) {
                viewModel.openSheet()
            }
            .accessibilityIdentifier("pressure-add-button")
        }
    }

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.screenState {
        case .loading:
            SkeletonList()
        case .error(let message):
            ErrorStateView(message: message, retry: { Task { await viewModel.reload() } })
        case .empty:
            latestCard
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
        SegmentedPicker(
            options: PressurePeriod.allCases,
            selection: $viewModel.period,
            title: { $0.title },
            identifierPrefix: "period"
        )
        latestCard
        chartCard
        PressureWhyCard(zone: viewModel.latest?.zone)
        PressureHistoryList(rows: viewModel.historyRows)
    }

    private var latestCard: some View {
        PressureLatestCard(
            zone: viewModel.latest?.zone,
            valueText: viewModel.latestValueText,
            dateText: viewModel.latestDateText,
            pulseText: viewModel.pulseText,
            rangeText: viewModel.rangeText,
            averageText: viewModel.averageText
        )
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "Динамика")
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
                    accessibilityValue: viewModel.chartAccessibilityValue
                )
            }
            PressureChartLegend()
        }
        .cardStyle()
    }
}

#Preview("Давление: данные") {
    let store = HealthStore(repository: MockHealthRepository(delayNanoseconds: 0))
    return PressureView(viewModel: PressureViewModel(store: store))
}

#Preview("Давление: loading") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .neverLoads))
    return PressureView(viewModel: PressureViewModel(store: store))
}

#Preview("Давление: empty") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .empty, delayNanoseconds: 0))
    return PressureView(viewModel: PressureViewModel(store: store))
}

#Preview("Давление: error") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .failure, delayNanoseconds: 0))
    return PressureView(viewModel: PressureViewModel(store: store))
}
