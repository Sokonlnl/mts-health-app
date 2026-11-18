import SwiftUI

/// Экран давления. Верхний блок по Figma 86:123: название с иконкой, значение 84 pt, единица, чип статуса, под ними
/// сердце в ритме пульса и затемнение к низу. Ниже подпись (дата, контекст, пульс), периоды, график, среднее и диапазон,
/// пояснение, колода советов ГигаЧата. Весь текст страницы крупнее на две ступени Dynamic Type. Добавления измерений нет.
struct PressureView: View {
    @Bindable var viewModel: PressureViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var isAdviceSwiping = false
    private static let scrollSpace = "pressureScroll"

    var body: some View {
        GeometryReader { _ in
            scroll
                .ignoresSafeArea(edges: .top)
        }
        .largerText(steps: Size.metricPageTextSteps)
        .statusBarFade(offset: scrollOffset)
        .background(AppColor.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }

    private var scroll: some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                hero
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

    /// Верхний блок (Figma 86:123), положения от верха экрана: название с иконкой с y=64, значение с y=103, сердце ниже,
    /// затемнение низа. Кнопка «назад» слева на уровне названия.
    private var hero: some View {
        ZStack(alignment: .top) {
            if case .content = viewModel.screenState {
                HeartGlow(color: viewModel.latestTone.colors.text, rhythm: viewModel.heartRhythm, placement: .hero)
            }
            LinearGradient(colors: [AppColor.heroFade, Color.clear], startPoint: .bottom, endPoint: .top)
                .frame(height: Size.metricHeroFadeHeight)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .allowsHitTesting(false)
            VStack(spacing: Size.metricHeroValueGap) {
                titleRow
                heroContent
            }
            .padding(.top, Size.metricHeroTitleTop)
            .padding(.horizontal, Spacing.screenMargin)
        }
        .frame(maxWidth: .infinity)
        .frame(height: viewModel.heroHeight, alignment: .top)
        .overlay(alignment: .topLeading) {
            IconButton(systemName: "chevron.left", label: "Назад") { dismiss() }
                .accessibilityIdentifier("back-button")
                .padding(.leading, Spacing.screenMargin)
                .padding(.top, Size.metricHeroBackTop)
        }
        .clipped()
    }

    private var titleRow: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: MetricKind.pressure.iconName)
                .textStyle(.icon)
                .foregroundStyle(AppColor.textPrimary)
                .accessibilityHidden(true)
            Text("Давление")
                .textStyle(.cardLabel)
                .foregroundStyle(AppColor.textPrimary)
                .accessibilityIdentifier("pressure-title")
                .accessibilityAddTraits(.isHeader)
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
                unitText: AppUnit.pressure,
                statusText: viewModel.latestStatusText,
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
        Text(viewModel.latestCaptionText)
            .textStyle(.body)
            .foregroundStyle(AppColor.textSecondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier("pressure-latest-caption")
        SegmentedPicker(
            options: PressurePeriod.allCases,
            selection: $viewModel.period,
            title: { $0.title },
            identifierPrefix: "period"
        )
        chartCard
        statCards
        PressureWhyCard(plates: viewModel.zonePlates, explanation: viewModel.explanationText)
        if viewModel.hasAdvice {
            AdviceDeckView(
                cards: viewModel.adviceCards,
                positionText: viewModel.advicePositionText,
                onDismiss: { viewModel.dismissAdvice() },
                onRefresh: { viewModel.refreshAdvice() },
                isSwiping: $isAdviceSwiping
            )
            .padding(.horizontal, Spacing.adviceInset)
            .accessibilityIdentifier("advice-card")
        }
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
