import SwiftUI

/// Главный экран: заголовок, пилюли, форма Aura, вывод, карточки показателей, плавающая навигация.
struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    let onOpenPressure: () -> Void
    @State private var tab: AppTab = .home

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                stateContent
            }
            .padding(.horizontal, Spacing.screenMargin)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.tabBarClearance)
            .auraScreenBackdrop(palette: viewModel.state.palette, glowHeight: Size.glowHomeHeight)
        }
        .background(AppColor.background)
        .auraBottomBar { bottomBar }
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }

    // MARK: - Состояния

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.screenState {
        case .loading:
            SkeletonOrb(diameter: Size.orbHome)
            SkeletonList(count: 2)
        case .error(let message):
            ErrorStateView(message: message, retry: { Task { await viewModel.reload() } })
        case .empty:
            pills
            HomeHeroOrb(hero: viewModel.hero)
            EmptyStateView(
                message: "Добавьте первое измерение давления, и здесь появится сводка за неделю.",
                action: onOpenPressure
            )
        case .content:
            pills
            HomeHeroOrb(hero: viewModel.hero)
            HomeHeadline(
                headline: viewModel.headline,
                isExpanded: viewModel.isInsightExpanded,
                onToggle: { withAnimation(Motion.standard) { viewModel.toggleInsight() } }
            )
            metrics
        }
    }

    // MARK: - Блоки

    private var header: some View {
        HStack(spacing: Spacing.m) {
            Text(viewModel.dateTitle)
                .textStyle(.title)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.title)
                .accessibilityIdentifier("home-title")
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            IconButton(systemName: "person.fill", label: "Профиль") { tab = .profile }
                .accessibilityIdentifier("profile-button")
        }
    }

    private var pills: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.pills) { pill in
                MetricPill(
                    kind: pill.kind,
                    valueText: pill.valueText,
                    state: pill.state,
                    isSelected: pill.isSelected,
                    accessibilityText: pill.accessibilityText
                ) {
                    withAnimation(Motion.palette) { viewModel.select(pill.kind) }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var metrics: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "Показатели")
            card(.pressure, layout: .wide)
                .accessibilityIdentifier("pressure-card")
            HStack(alignment: .top, spacing: Spacing.m) {
                card(.pulse)
                card(.weight)
            }
            .fixedSize(horizontal: false, vertical: true)
            card(.glucose)
        }
    }

    private func card(_ kind: MetricKind, layout: MetricCard.Layout = .compact) -> some View {
        let model = viewModel.card(kind)
        let isPressure = kind == .pressure
        let noAction: () -> Void = {}
        return MetricCard(
            kind: kind,
            valueText: model.valueText,
            unit: model.unit,
            statusText: model.statusText,
            tone: model.tone,
            series: model.series,
            layout: layout,
            weekBars: isPressure ? viewModel.weekBars : [],
            // Экранов ввода пульса, веса и глюкозы пока нет: у этих карточек кнопка без действия.
            onAdd: isPressure ? onOpenPressure : noAction,
            onOpen: isPressure ? onOpenPressure : nil
        )
    }

    private var bottomBar: some View {
        HStack(spacing: Spacing.m) {
            FloatingTabBar(selection: $tab)
            IconButton(systemName: "plus", label: "Добавить измерение", diameter: Size.navAdd, action: onOpenPressure)
                .accessibilityIdentifier("add-button")
        }
    }
}

#Preview("Home: данные") {
    let store = HealthStore(repository: MockHealthRepository(delayNanoseconds: 0))
    return HomeView(viewModel: HomeViewModel(store: store), onOpenPressure: {})
        .preferredColorScheme(.dark)
}

#Preview("Home: loading") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .neverLoads))
    return HomeView(viewModel: HomeViewModel(store: store), onOpenPressure: {})
        .preferredColorScheme(.dark)
}

#Preview("Home: empty") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .empty, delayNanoseconds: 0))
    return HomeView(viewModel: HomeViewModel(store: store), onOpenPressure: {})
        .preferredColorScheme(.dark)
}

#Preview("Home: error") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .failure, delayNanoseconds: 0))
    return HomeView(viewModel: HomeViewModel(store: store), onOpenPressure: {})
        .preferredColorScheme(.dark)
}
