import SwiftUI

/// Экран давления в стиле нового главного: верхний блок со свечением и скруглением снизу (шапка, последнее измерение),
/// периоды, график, среднее и диапазон, пояснение, история. Добавления измерений нет: экран только показывает данные.
struct PressureView: View {
    @Bindable var viewModel: PressureViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    private static let scrollSpace = "pressureScroll"

    var body: some View {
        GeometryReader { proxy in
            scroll(topInset: proxy.safeAreaInsets.top)
                .ignoresSafeArea(edges: .top)
        }
        .statusBarFade(offset: scrollOffset)
        .background(AppColor.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }

    private func scroll(topInset: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                hero(topInset: topInset)
                VStack(alignment: .leading, spacing: Spacing.l) {
                    cards
                }
                .padding(.horizontal, Spacing.screenMargin)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, Spacing.tabBarClearance)
            .reportsScrollOffset(in: Self.scrollSpace, offset: $scrollOffset, maxOffset: Size.statusBarFadeRamp)
        }
        .coordinateSpace(name: Self.scrollSpace)
    }

    // MARK: - Верхний блок

    /// Верхний блок со свечением по зоне последнего измерения: шапка и крупное значение.
    private func hero(topInset: CGFloat) -> some View {
        VStack(spacing: Spacing.xl) {
            header
            heroContent
        }
        .padding(.horizontal, Spacing.screenMargin)
        .padding(.top, topInset + Spacing.s)
        .padding(.bottom, Spacing.xxl)
        .frame(maxWidth: .infinity, minHeight: viewModel.heroHeight, alignment: .top)
        .background { DomeGlow(palette: viewModel.latestState.palette, isAnimated: viewModel.screenState != .loading) }
    }

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
            // Пустое место вместо «+»: заголовок остаётся по центру.
            Color.clear
                .frame(width: Size.iconButton, height: Size.iconButton)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var heroContent: some View {
        switch viewModel.screenState {
        case .loading:
            SkeletonHeadline(identifier: "skeleton-hero")
        case .error:
            EmptyView()
        case .empty, .content:
            PressureHero(
                tone: viewModel.latestTone,
                isPlaceholder: viewModel.latestIsPlaceholder,
                valueText: viewModel.latestValueText,
                unitText: viewModel.latestUnitText,
                statusText: viewModel.latestStatusText,
                subtitle: viewModel.latestSubtitleText,
                accessibilityText: viewModel.latestAccessibilityText
            )
        }
    }

    // MARK: - Состояния

    @ViewBuilder
    private var cards: some View {
        switch viewModel.screenState {
        case .loading:
            SkeletonList(count: 2)
        case .error(let message):
            ErrorStateView(message: message, retry: { Task { await viewModel.reload() } })
        case .empty:
            EmptyStateView(message: viewModel.emptyMessage)
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
        chartCard
        statCards
        PressureWhyCard(plates: viewModel.zonePlates, explanation: viewModel.explanationText)
        PressureHistoryList(rows: viewModel.historyRows, emptyText: viewModel.emptyPeriodMessage)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "Динамика", isCompact: true)
            if viewModel.hasPeriodMeasurements {
                PressureChartView(
                    measurements: viewModel.periodMeasurements,
                    period: viewModel.period,
                    xDomain: viewModel.chartXDomain,
                    yDomain: viewModel.chartYDomain,
                    markerColor: viewModel.latestState.palette.markerGlow,
                    accessibilityValue: viewModel.chartAccessibilityValue
                )
                .contentSwap(viewModel.period)
            } else {
                Text(viewModel.emptyPeriodMessage)
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: Size.chartEmpty)
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
                detailTone: viewModel.averageTone
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
