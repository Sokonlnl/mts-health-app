import SwiftUI

/// Главный экран (эталон Figma 47:2127): свечение-купол, кнопка профиля, компактный вывод в зоне свечения,
/// ряд плиток, кнопка «Давление», секция «Показатели», плавающая навигация.
struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    let onOpenPressure: () -> Void
    @State private var tab: AppTab = .home

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    domeArea(topInset: proxy.safeAreaInsets.top)
                    VStack(spacing: Spacing.m) {
                        stateContent
                    }
                    .padding(.horizontal, Spacing.screenMargin)
                    .padding(.bottom, Spacing.tabBarClearance)
                }
                .frame(maxWidth: .infinity)
                .background(alignment: .top) {
                    DomeGlow(palette: viewModel.glowState.palette, isAnimated: !viewModel.isLoading)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(AppColor.homeBackground.ignoresSafeArea())
        .auraBottomBar(fadeColor: AppColor.homeBackground, fadeHeight: Size.homeBottomFadeHeight) { bottomBar }
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }

    // MARK: - Свечение, профиль и вывод

    /// Верхняя зона до ряда плиток. Вывод показывается только с данными: в loading, empty и error его нет.
    private func domeArea(topInset: CGFloat) -> some View {
        ZStack(alignment: .top) {
            Color.clear.frame(height: viewModel.tilesTop)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    IconButton(systemName: "person", label: "Профиль", surface: .profile) { tab = .profile }
                        .accessibilityIdentifier("profile-button")
                }
                Spacer(minLength: Spacing.l)
                if viewModel.showsInsight {
                    HomeHeadline(
                        headline: viewModel.headline,
                        isExpanded: viewModel.isInsightExpanded,
                        onToggle: { withAnimation(Motion.standard) { viewModel.toggleInsight() } }
                    )
                    .shadow(color: AppColor.textShadow, radius: Size.textShadowRadius)
                }
            }
            .padding(.top, topInset)
            .padding(.bottom, Spacing.l)
        }
        .padding(.horizontal, Spacing.screenMargin)
    }

    // MARK: - Состояния

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.screenState {
        case .loading:
            HStack(spacing: Spacing.tileGap) {
                SkeletonTile(identifier: "loading-state")
                SkeletonTile()
                SkeletonTile()
            }
            SkeletonList(count: 2, firstIdentifier: "skeleton-card")
        case .error(let message):
            ErrorStateView(message: message, retry: { Task { await viewModel.reload() } })
        case .empty:
            tilesRow
            EmptyStateView(
                message: viewModel.emptyMessage,
                action: onOpenPressure
            )
        case .content:
            tilesRow
            GlowButton(title: "Давление", systemImage: "play.fill", action: onOpenPressure)
                .accessibilityIdentifier("pressure-button")
            metrics
        }
    }

    // MARK: - Блоки

    private var tilesRow: some View {
        HStack(spacing: Spacing.tileGap) {
            ForEach(viewModel.tiles) { tile in
                let content = MetricCard(
                    kind: tile.kind,
                    valueText: tile.valueText,
                    unit: tile.unit,
                    statusText: tile.statusText,
                    tone: tile.tone,
                    layout: .tile
                )
                if tile.kind == .pressure {
                    Button(action: onOpenPressure) { content }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("pressure-card")
                } else {
                    content
                }
            }
        }
    }

    private var metrics: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "Показатели")
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(alignment: .top, spacing: Spacing.m) {
                solidMetricCard(.pulse)
                solidMetricCard(.weight)
            }
            .fixedSize(horizontal: false, vertical: true)
            glucoseCard
        }
    }

    private func solidMetricCard(_ kind: MetricKind) -> some View {
        let model = viewModel.card(kind)
        return MetricCard(
            kind: kind,
            valueText: model.valueText,
            unit: model.unit,
            statusText: model.statusText,
            tone: model.tone,
            series: model.series,
            surface: .solid,
            showsSparkline: model.showsSparkline
        )
    }

    private var glucoseCard: some View {
        let model = viewModel.card(.glucose)
        // Экрана ввода глюкозы нет: кнопка пустой карточки выключена и подписана (без действия).
        return MetricCard(
            kind: .glucose,
            valueText: model.valueText,
            unit: model.unit,
            statusText: model.statusText,
            tone: model.tone,
            series: model.series
        )
    }

    private var bottomBar: some View {
        FloatingTabBar(selection: $tab)
    }
}

private struct PreviewRepository: HealthRepository {
    let data: HealthData

    func load() async throws -> HealthData { data }
}

/// Главный экран с последним измерением давления заданной зоны (для превью палитры свечения).
@MainActor
private func previewHome(systolic: Int, diastolic: Int) -> some View {
    var data = MockHealthData.make(now: Date())
    let latest = PressureMeasurement(
        id: "preview", date: Date(), systolic: systolic, diastolic: diastolic, pulse: 70, context: nil
    )
    data.pressure.insert(latest, at: 0)
    let store = HealthStore(repository: PreviewRepository(data: data))
    return HomeView(viewModel: HomeViewModel(store: store), onOpenPressure: {})
        .preferredColorScheme(.dark)
}

#Preview("Home: данные (норма)") {
    let store = HealthStore(repository: MockHealthRepository(delayNanoseconds: 0))
    return HomeView(viewModel: HomeViewModel(store: store), onOpenPressure: {})
        .preferredColorScheme(.dark)
}

#Preview("Home: повышенное") {
    previewHome(systolic: 134, diastolic: 86)
}

#Preview("Home: высокое") {
    previewHome(systolic: 148, diastolic: 94)
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
