import SwiftUI

/// Главный экран (эталон Figma 63:25250): верхний блок со свечением (вкладки, профиль, вывод), большая карточка давления,
/// малые карточки веса и глюкозы, блок «Советы от ГигаЧата» с кнопкой, плавающая навигация поверх прокрутки.
struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    let onOpenPressure: () -> Void
    @State private var tab: AppTab = .home
    @State private var scrollOffset: CGFloat = 0
    /// Смещение страниц во время горизонтального жеста между вкладками.
    @State private var pageDrag: CGFloat = 0
    /// Заставка: свечение разгорелось из темноты. Без заставки сразу `true`.
    @State private var isGlowLit: Bool
    private let gate = AmbientMotionGate()
    private static let scrollSpace = "homeScroll"

    init(viewModel: HomeViewModel, onOpenPressure: @escaping () -> Void) {
        _viewModel = Bindable(viewModel)
        self.onOpenPressure = onOpenPressure
        _isGlowLit = State(initialValue: !viewModel.isIntroPending)
    }

    /// Заставка идёт, пока она не сыграна, при включённом движении.
    private var isIntroActive: Bool { viewModel.isIntroPending && gate.isEnabled }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                pages(width: proxy.size.width, topInset: proxy.safeAreaInsets.top)
                // Заголовки вкладок одним слоем над страницами: один набор элементов для VoiceOver и XCUI.
                tabsRow
            }
            .ignoresSafeArea(edges: .top)
        }
        .statusBarFade(offset: scrollOffset)
        .background(AppColor.background.ignoresSafeArea())
        .auraBottomBar(fadeColor: AppColor.background, fadeHeight: Size.homeBottomFadeHeight) { FloatingTabBar(selection: $tab) }
        .toast(message: $viewModel.toastMessage)
        .toolbar(.hidden, for: .navigationBar)
        .task { await run() }
    }

    /// Загрузка и заставка: свечение разгорается сразу, элементы появляются по очереди после загрузки, затем заставка завершена.
    private func run() async {
        if isIntroActive {
            withAnimation(Motion.introGlow) { isGlowLit = true }
        }
        await viewModel.load()
        await viewModel.runIntro(animationsEnabled: gate.isEnabled)
    }

    /// Две страницы рядом («Самочувствие» и «Анализы») со сдвигом по выбранной вкладке и свайпом между ними.
    /// Постраничный `TabView` не используется: вложенная в него вертикальная прокрутка после оттягивания вниз оставалась
    /// сдвинутой, и верхний блок не доходил до края экрана.
    private func pages(width: CGFloat, topInset: CGFloat) -> some View {
        let index = viewModel.selectedTabID == HomeViewModel.analysesTabID ? 1 : 0
        return HStack(spacing: 0) {
            scroll(topInset: topInset).frame(width: width)
            analysesPage.frame(width: width)
        }
        .frame(width: width, alignment: .leading)
        .offset(x: -CGFloat(index) * width + pageDrag)
        .animation(gate.isEnabled ? Motion.standard : nil, value: index)
        .clipped()
        .simultaneousGesture(
            DragGesture(minimumDistance: Spacing.l)
                .onChanged { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    // С первой страницы тянуть можно только влево, со второй только вправо.
                    pageDrag = index == 0 ? min(0, value.translation.width) : max(0, value.translation.width)
                }
                .onEnded { value in
                    let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                    let travelled = abs(value.predictedEndTranslation.width) > width * Size.pageSwitchFraction
                    if isHorizontal, travelled {
                        viewModel.selectTab(index == 0 ? HomeViewModel.analysesTabID : HomeViewModel.wellbeingTabID)
                    }
                    withAnimation(gate.isEnabled ? Motion.standard : nil) { pageDrag = 0 }
                }
        )
    }

    private func scroll(topInset: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: Spacing.columnGap) {
                hero(topInset: topInset)
                VStack(spacing: Spacing.columnGap) {
                    stateContent
                }
                .padding(.horizontal, Spacing.screenMargin)
                .padding(.top, Spacing.heroCardExtraGap)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, Spacing.homeBottomClearance)
            .reportsScrollOffset(in: Self.scrollSpace, offset: $scrollOffset, maxOffset: Size.heroTabsFadeRamp)
        }
        .coordinateSpace(name: Self.scrollSpace)
    }

    // MARK: - Верхний блок

    /// Верхний блок: свечение по зоне давления, вкладки, профиль и вывод. В loading на месте вывода скелетон,
    /// в empty и error блок компактный и без вывода.
    private func hero(topInset: CGFloat) -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                if viewModel.showsInsight {
                    HomeHeadline(
                        headline: viewModel.headline,
                        isExpanded: viewModel.isInsightExpanded,
                        onToggle: { withAnimation(gate.isEnabled ? Motion.standard : nil) { viewModel.toggleInsight() } }
                    )
                    .introReveal(index: 0, isActive: isIntroActive)
                    .padding(.top, Size.heroInsightTop)
                } else if viewModel.isLoading {
                    SkeletonHeadline()
                        .padding(.top, Size.heroInsightTop)
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                AvatarButton(
                    imageName: "ProfileAvatar", label: "Профиль", tint: viewModel.glowState.palette.profileTint
                ) { tab = .profile }
                    .padding(.trailing, Spacing.s)
                    .accessibilityIdentifier("profile-button")
            }
            .padding(.top, topInset - Size.profileButtonLift)
        }
        .padding(.horizontal, Spacing.screenMargin)
        .frame(maxWidth: .infinity, minHeight: viewModel.heroHeight, alignment: .top)
        .background {
            HeroGlowImage(
                palette: viewModel.glowState.palette, isAnimated: !viewModel.isLoading,
                level: isGlowLit || !gate.isEnabled ? 1 : 0
            )
        }
    }

    /// Заголовки вкладок «Самочувствие» и «Анализы»: тап меняет страницу, как и свайп.
    private var tabsRow: some View {
        SegmentedPicker(
            options: viewModel.tabs,
            selection: Binding(get: { viewModel.selectedTab }, set: { viewModel.selectTab($0.id) }),
            title: { $0.title },
            style: .tabs,
            identifier: { "tab-" + $0.id }
        )
        .padding(.top, Size.heroTabsTop)
        .frame(maxWidth: .infinity, alignment: .top)
        .opacity(1 - Double(min(1, max(0, scrollOffset / Size.heroTabsFadeRamp))))
        .allowsHitTesting(scrollOffset < Size.heroTabsFadeRamp / 2)
    }

    /// Вкладка «Анализы»: заглушка «Ещё в прогрессе» по центру (заголовки вкладок рисует `tabsRow` поверх страниц).
    private var analysesPage: some View {
        ZStack(alignment: .top) {
            StateMessageView(
                icon: "hourglass", title: HomeText.analysesTitle, message: HomeText.analysesMessage,
                identifier: "analyses-placeholder"
            )
            .padding(.horizontal, Spacing.screenMargin)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Состояния

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.screenState {
        case .loading:
            SkeletonCard(identifier: "skeleton-card", minHeight: Size.pressureCardHeight, radius: Radius.heroCard)
            HStack(spacing: Spacing.tileGap) {
                SkeletonCard(minHeight: Size.smallCardHeight, radius: Radius.tile)
                SkeletonCard(minHeight: Size.smallCardHeight, radius: Radius.tile)
            }
            SkeletonButton()
        case .error(let message):
            ErrorStateView(message: message, retry: { Task { await viewModel.reload() } })
        case .empty:
            pressureCard
            smallCards
            EmptyStateView(message: viewModel.emptyMessage)
        case .content:
            pressureCard.introReveal(index: 1, isActive: isIntroActive)
            smallCards.introReveal(index: 2, isActive: isIntroActive)
            adviceBlock
            GlowButton(title: HomeText.gigachatButton, systemImage: "sparkles") { viewModel.showComingSoon() }
                .introReveal(index: 4, isActive: isIntroActive)
                .frame(maxWidth: Size.glowButtonWidth)
                .accessibilityIdentifier("gigachat-button")
                .accessibilityHint(HomeText.comingSoonHint)
        }
    }

    // MARK: - Блоки

    private var pressureCard: some View {
        Button(action: onOpenPressure) { metricCard(viewModel.pressureCard, layout: .large) }
            .buttonStyle(.plain)
            .accessibilityHint(HomeText.openPressureHint)
            .accessibilityIdentifier("pressure-card")
    }

    /// Вес и глюкоза в ряд, одинаковой высоты.
    private var smallCards: some View {
        HStack(spacing: Spacing.tileGap) {
            ForEach(viewModel.smallCards) { model in
                metricCard(model, layout: .small)
                    .accessibilityIdentifier("metric-card-\(model.kind.rawValue)")
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var adviceBlock: some View {
        Text(HomeText.adviceSectionTitle)
            .textStyle(.sectionTitle)
            .foregroundStyle(AppColor.textPrimary)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(TextScale.title)
            .frame(maxWidth: .infinity)
            .introReveal(index: 3, isActive: isIntroActive)
            .padding(.top, Spacing.xxl)
            .accessibilityAddTraits(.isHeader)
        if !viewModel.adviceCards.isEmpty {
            AdviceDeckView(
                cards: viewModel.adviceCards, positionText: viewModel.advicePositionText,
                onNext: { viewModel.showNextAdvice() }, onPrevious: { viewModel.showPreviousAdvice() }
            )
            .introReveal(index: 3, isActive: isIntroActive)
            .padding(.horizontal, Spacing.adviceInset)
            .padding(.bottom, Spacing.xl)
            .accessibilityIdentifier("advice-card")
        }
    }

    private func metricCard(_ model: MetricCardModel, layout: MetricCard.Layout) -> some View {
        MetricCard(
            kind: model.kind,
            valueText: model.displayValue,
            isPlaceholder: model.isPlaceholder,
            unit: model.captionText,
            statusText: model.statusText,
            tone: model.tone,
            layout: layout,
            gauge: model.gauge,
            gaugePosition: model.gaugePosition,
            rhythm: model.rhythm,
            accessibilityText: model.accessibilityText
        )
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
