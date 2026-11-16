import SwiftUI

/// Главный экран.
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
        }
        .safeAreaInset(edge: .bottom) { bottomBar }
        .background(AppColor.background)
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }

    // MARK: - Состояния

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.screenState {
        case .loading:
            SkeletonList()
        case .error(let message):
            ErrorStateView(message: message, retry: { Task { await viewModel.reload() } })
        case .empty:
            EmptyStateView(
                message: "Добавьте первое измерение давления, и здесь появится сводка за неделю.",
                action: onOpenPressure
            )
            content
        case .content:
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        if let syncText = viewModel.syncText {
            StatusPill(text: syncText, tone: .positive, systemImage: "checkmark.circle.fill")
        }
        overviewCard
        WeekStrip(days: viewModel.weekDays)
        SectionHeader(title: "Показатели")
        ForEach(viewModel.cards) { card in
            metricCard(card)
        }
    }

    // MARK: - Блоки

    private var header: some View {
        HStack(spacing: Spacing.m) {
            HStack(spacing: Spacing.s) {
                Text(viewModel.dateTitle)
                    .textStyle(.title)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(TextScale.title)
                    .accessibilityIdentifier("home-title")
                    .accessibilityAddTraits(.isHeader)
                Image(systemName: "chevron.down")
                    .font(AppTextStyle.bodyStrong.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
            Image(systemName: "person.fill")
                .font(AppTextStyle.bodyStrong.font)
                .foregroundStyle(AppColor.accent)
                .frame(width: Size.avatar, height: Size.avatar)
                .background(AppColor.accentSoft, in: Circle())
                .accessibilityLabel("Профиль")
        }
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            HStack(alignment: .center, spacing: 0) {
                ForEach(Array(viewModel.rings.enumerated()), id: \.element.id) { index, ring in
                    if index > 0 {
                        Hairline(verticalLength: Size.ring)
                    }
                    RingGauge(
                        progress: ring.progress,
                        color: ring.kind.color,
                        centerText: ring.centerText,
                        caption: ring.kind.title,
                        isEmpty: ring.isEmpty,
                        accessibilityText: ring.accessibilityText
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            Hairline()
            insightBlock
        }
        .cardStyle(radius: Radius.hero)
    }

    private var insightBlock: some View {
        let insight = viewModel.insight
        return VStack(alignment: .leading, spacing: Spacing.s) {
            Text(insight.title)
                .textStyle(.headline)
                .foregroundStyle(AppColor.textPrimary)
            Text(insight.summary)
                .textStyle(.body)
                .foregroundStyle(AppColor.textSecondary)
            if viewModel.isInsightExpanded {
                Text(insight.details)
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("insight-details")
            }
            Button {
                withAnimation(Motion.standard) {
                    viewModel.toggleInsight()
                }
            } label: {
                HStack(spacing: Spacing.xs) {
                    Text(viewModel.isInsightExpanded ? "Свернуть" : "Подробнее")
                        .textStyle(.bodyStrong)
                    Image(systemName: viewModel.isInsightExpanded ? "chevron.up" : "chevron.down")
                        .font(AppTextStyle.captionStrong.font)
                        .accessibilityHidden(true)
                }
                .foregroundStyle(AppColor.accent)
                .frame(minHeight: Spacing.minTapTarget)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("insight-toggle")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func metricCard(_ card: MetricCardModel) -> some View {
        let view = MetricCard(
            kind: card.kind,
            valueText: card.valueText,
            unit: card.unit,
            statusText: card.statusText,
            tone: card.tone,
            series: card.series
        )
        if card.kind == .pressure {
            Button(action: onOpenPressure) { view }
                .buttonStyle(.plain)
                .accessibilityIdentifier("pressure-card")
        } else {
            view
        }
    }

    private var bottomBar: some View {
        HStack(spacing: Spacing.m) {
            FloatingTabBar(selection: $tab)
            IconButton(
                systemName: "plus",
                label: "Добавить измерение",
                style: .accent,
                diameter: Size.addButton,
                action: onOpenPressure
            )
            .accessibilityIdentifier("add-button")
        }
        .padding(.horizontal, Spacing.screenMargin)
        .padding(.bottom, Spacing.s)
    }
}

#Preview("Home: данные") {
    let store = HealthStore(repository: MockHealthRepository(delayNanoseconds: 0))
    return HomeView(viewModel: HomeViewModel(store: store), onOpenPressure: {})
}

#Preview("Home: loading") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .neverLoads))
    return HomeView(viewModel: HomeViewModel(store: store), onOpenPressure: {})
}

#Preview("Home: empty") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .empty, delayNanoseconds: 0))
    return HomeView(viewModel: HomeViewModel(store: store), onOpenPressure: {})
}

#Preview("Home: error") {
    let store = HealthStore(repository: MockHealthRepository(scenario: .failure, delayNanoseconds: 0))
    return HomeView(viewModel: HomeViewModel(store: store), onOpenPressure: {})
}
