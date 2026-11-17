import SwiftUI

/// Главный экран (эталон Figma 47:2127): короткое свечение-купол, кнопка профиля, вывод по центру,
/// колонка (кнопка «Давление», «Показатели», бенто), карточки «Пульс» и «Глюкоза», плавающая навигация.
struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    let onOpenPressure: () -> Void
    @State private var tab: AppTab = .home

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    domeArea(topInset: proxy.safeAreaInsets.top)
                    VStack(spacing: Spacing.columnGap) {
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
            .ignoresSafeArea(edges: .top)
        }
        .background(AppColor.homeBackground.ignoresSafeArea())
        .auraBottomBar(fadeColor: AppColor.homeBackground, fadeHeight: Size.homeBottomFadeHeight) { bottomBar }
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }

    // MARK: - Свечение, профиль и вывод

    /// Верхняя зона до колонки. Вывод стоит по центру от `homeInsightTop` и растёт вниз при развороте.
    /// В loading на его месте скелетон, в empty и error вывода нет.
    private func domeArea(topInset: CGFloat) -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                if viewModel.showsInsight {
                    HomeHeadline(
                        headline: viewModel.headline,
                        isExpanded: viewModel.isInsightExpanded,
                        onToggle: { withAnimation(Motion.standard) { viewModel.toggleInsight() } }
                    )
                    .shadow(color: AppColor.textShadow, radius: Size.textShadowRadius)
                    .padding(.top, Size.homeInsightTop)
                } else if viewModel.isLoading {
                    SkeletonHeadline()
                        .padding(.top, Size.homeInsightTop)
                }
            }
            .frame(maxWidth: .infinity, minHeight: viewModel.columnTop, alignment: .top)
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                IconButton(systemName: "person", label: "Профиль", surface: .profile) { tab = .profile }
                    .accessibilityIdentifier("profile-button")
            }
            .padding(.top, topInset)
        }
        .padding(.horizontal, Spacing.screenMargin)
    }

    // MARK: - Состояния

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.screenState {
        case .loading:
            SkeletonButton()
            metricsHeader
            BentoGrid {
                SkeletonTile()
            } side: {
                SkeletonTile()
                SkeletonTile()
            }
            SkeletonList(count: 2, firstIdentifier: "skeleton-card")
        case .error(let message):
            ErrorStateView(message: message, retry: { Task { await viewModel.reload() } })
        case .empty:
            metricsHeader
            bento
            EmptyStateView(
                message: viewModel.emptyMessage,
                action: onOpenPressure
            )
        case .content:
            GlowButton(title: "Давление", systemImage: "play.fill", action: onOpenPressure)
                .accessibilityIdentifier("pressure-button")
            metricsHeader
            bento
            // Экрана ввода глюкозы нет: кнопка пустой карточки выключена и подписана (без действия).
            ForEach(viewModel.listCards) { model in
                metricCard(model, layout: .compact)
            }
        }
    }

    // MARK: - Блоки

    private var metricsHeader: some View {
        SectionHeader(title: "Показатели")
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Бенто: большая плитка давления (открывает экран давления) и две плитки справа.
    private var bento: some View {
        BentoGrid {
            Button(action: onOpenPressure) { metricCard(viewModel.pressureTile, layout: .tile) }
                .buttonStyle(.plain)
                .accessibilityIdentifier("pressure-card")
        } side: {
            ForEach(viewModel.sideTiles) { metricCard($0, layout: .tile) }
        }
    }

    private func metricCard(_ model: MetricCardModel, layout: MetricCard.Layout) -> some View {
        MetricCard(
            kind: model.kind,
            valueText: model.valueText,
            unit: model.unit,
            statusText: model.statusText,
            tone: model.tone,
            series: model.series,
            layout: layout,
            surface: model.surface,
            sparklineStyle: model.sparklineStyle
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
