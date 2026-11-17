import SwiftUI

/// Стеклянная карточка показателя на главном экране.
/// `wide`: давление, значение 44 и 7 столбиков недели справа. `compact`: пульс и вес, значение 38 и мини-график.
/// Пустое состояние: `valueText == nil` (прочерк, пунктир, контурная кнопка «Добавить измерение»).
struct MetricCard: View {
    enum Layout {
        case wide
        case compact
    }

    let kind: MetricKind
    let valueText: String?
    let unit: String
    let statusText: String
    let tone: StatusTone
    let series: [Double]
    var layout: Layout = .compact
    var weekBars: [WeekBar] = []
    /// Кнопка «+» в шапке и кнопка пустой карточки.
    var onAdd: (() -> Void)?
    /// Нажатие на всю карточку.
    var onOpen: (() -> Void)?

    private var isWide: Bool { layout == .wide }
    private var insets: EdgeInsets { isWide ? CardInsets.standard : CardInsets.compact }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            header
            if isWide {
                wideBody
            } else {
                compactBody
            }
            if valueText == nil, let onAdd {
                PrimaryButton(title: "Добавить измерение", style: .outline, action: onAdd)
                    .accessibilityIdentifier("metric-empty-add-\(kind.rawValue)")
            }
        }
        .glassCard(radius: isWide ? Radius.card : Radius.cardSmall, insets: insets)
        .overlay { openButton }
        .overlay(alignment: .topTrailing) { addButton }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Блоки

    private var header: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: kind.iconName)
                .font(AppTextStyle.captionStrong.font)
                .foregroundStyle(kind.color)
                .frame(width: Size.metricIcon, height: Size.metricIcon)
                .background(AppColor.fill, in: Circle())
                .accessibilityHidden(true)
            Text(kind.title)
                .textStyle(.label)
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(1)
            Spacer(minLength: 0)
            if onAdd != nil {
                // Место под кнопку «+»: сама кнопка лежит поверх карточки, чтобы не попадать под нажатие всей карточки.
                Color.clear
                    .frame(width: Size.iconButton, height: Size.iconButton)
                    .accessibilityHidden(true)
            }
        }
    }

    private var wideBody: some View {
        HStack(alignment: .bottom, spacing: Spacing.l) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                MetricValueText(value: valueText ?? AppFormat.dash, unit: "", isPlaceholder: valueText == nil, spacing: 0)
                HStack(spacing: Spacing.xs) {
                    Text(statusText)
                        .textStyle(.captionStrong)
                        .foregroundStyle(tone.colors.text)
                    Text("· \(unit)")
                        .textStyle(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .lineLimit(1)
                .minimumScaleFactor(TextScale.compact)
            }
            Spacer(minLength: 0)
            if valueText != nil, !weekBars.isEmpty {
                WeekBarsChart(bars: weekBars)
            }
        }
    }

    private var compactBody: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            MetricValueText(
                value: valueText ?? AppFormat.dash,
                unit: unit,
                style: .metricCardSmall,
                isPlaceholder: valueText == nil
            )
            Text(statusText)
                .textStyle(.captionStrong)
                .foregroundStyle(tone.colors.text)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Spacing.xs)
            Sparkline(values: series, color: kind.color, style: sparklineStyle)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var sparklineStyle: Sparkline.Style {
        switch kind {
        case .pulse: return .marker
        case .weight: return .forecast
        case .pressure, .glucose: return .line
        }
    }

    @ViewBuilder
    private var openButton: some View {
        if let onOpen {
            Button(action: onOpen) {
                Color.clear.contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Открыть: \(kind.title)")
        }
    }

    @ViewBuilder
    private var addButton: some View {
        if let onAdd {
            IconButton(systemName: "plus", label: "Добавить измерение: \(kind.title)", action: onAdd)
                .padding(.top, insets.top)
                .padding(.trailing, insets.trailing)
                .accessibilityIdentifier("metric-add-\(kind.rawValue)")
        }
    }
}

private enum PreviewSamples {
    static let bars = [
        WeekBar(id: 0, label: "Ср", systolic: 118, isElevated: false, isToday: false, ratio: 0.4),
        WeekBar(id: 1, label: "Чт", systolic: 124, isElevated: false, isToday: false, ratio: 0.55),
        WeekBar(id: 2, label: "Пт", systolic: 134, isElevated: true, isToday: false, ratio: 0.8),
        WeekBar(id: 3, label: "Сб", systolic: nil, isElevated: false, isToday: false, ratio: 0),
        WeekBar(id: 4, label: "Вс", systolic: 121, isElevated: false, isToday: false, ratio: 0.45),
        WeekBar(id: 5, label: "Пн", systolic: 126, isElevated: false, isToday: false, ratio: 0.6),
        WeekBar(id: 6, label: "Вт", systolic: 122, isElevated: false, isToday: true, ratio: 0.5)
    ]
}

#Preview("MetricCard: значения") {
    VStack(spacing: Spacing.l) {
        MetricCard(
            kind: .pressure, valueText: "122/79", unit: AppUnit.pressure, statusText: "Норма", tone: .positive,
            series: [], layout: .wide, weekBars: PreviewSamples.bars, onAdd: {}, onOpen: {}
        )
        HStack(alignment: .top, spacing: Spacing.m) {
            MetricCard(
                kind: .pulse, valueText: "68", unit: AppUnit.pulse,
                statusText: "В покое", tone: .neutral, series: [66, 68, 65, 70, 67], onAdd: {}
            )
            MetricCard(
                kind: .weight, valueText: "72,4", unit: AppUnit.weight,
                statusText: "−0,8 кг за 2 недели", tone: .neutral, series: [73.2, 73, 72.8, 72.6, 72.4], onAdd: {}
            )
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("MetricCard: тона статуса") {
    VStack(spacing: Spacing.l) {
        MetricCard(
            kind: .pressure, valueText: "134/86", unit: AppUnit.pressure, statusText: "Повышенное", tone: .caution,
            series: [], layout: .wide, weekBars: PreviewSamples.bars, onAdd: {}
        )
        MetricCard(
            kind: .pressure, valueText: "148/94", unit: AppUnit.pressure, statusText: "Высокое", tone: .critical,
            series: [], layout: .wide, weekBars: PreviewSamples.bars, onAdd: {}
        )
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("MetricCard: пусто") {
    MetricCard(
        kind: .glucose, valueText: nil, unit: AppUnit.glucose,
        statusText: "Измерений пока нет", tone: .neutral, series: [], onAdd: {}
    )
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

// У карточки показателя loading и error показываются на уровне экрана: скелетон и сообщение об ошибке.
#Preview("MetricCard: loading") {
    SkeletonList(count: 2)
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}

#Preview("MetricCard: error") {
    ErrorStateView(message: "Сервис временно недоступен. Проверьте соединение и повторите попытку.", retry: {})
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
