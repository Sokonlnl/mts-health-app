import SwiftUI

/// Карточка показателя на главном экране.
///
/// Раскладка (`layout`):
/// - `.tile`: стеклянная плитка 126 pt (подпись, значение, единица, статус зоны текстом), без иконки и графика.
/// - `.compact`: карточка с иконкой, значением, статусом и мини-графиком.
///
/// Поверхность (`surface`) у `.compact`: `.glass` (стекло, радиус 28) или `.solid` (#202020, контур #383838,
/// радиус 32, контент по центру). Цвет статуса задаёт `tone`.
/// Пустое состояние: `valueText == nil` (прочерк; VoiceOver читает «Нет данных»).
struct MetricCard: View {
    enum Layout {
        case tile
        case compact
    }

    enum Surface {
        case glass
        case solid
    }

    let kind: MetricKind
    let valueText: String?
    let unit: String
    var statusText: String?
    var tone: StatusTone = .neutral
    var series: [Double] = []
    var layout: Layout = .compact
    var surface: Surface = .glass
    /// Мини-график в `.compact`.
    var showsSparkline = true
    /// Действие кнопки пустой карточки. `nil`: кнопка выключена.
    var onAdd: (() -> Void)?

    private var isSolid: Bool { surface == .solid }

    var body: some View {
        switch layout {
        case .tile:
            tileBody
        case .compact:
            surfaced(compactBody)
        }
    }

    // MARK: - Плитка

    private var tileBody: some View {
        VStack(spacing: Spacing.xs) {
            Text(kind.title)
                .textStyle(.tileLabel)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.compact)
            Text(valueText ?? AppFormat.dash)
                .textStyle(.tileValue)
                .foregroundStyle(valueText == nil ? AppColor.textTertiary : AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.metric)
                .accessibilityHidden(valueText == nil)
            Text(unit)
                .textStyle(.tileUnit)
                .foregroundStyle(AppColor.neutral.text)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.compact)
            if let statusText {
                Text(statusText)
                    .textStyle(.tileUnit)
                    .foregroundStyle(tone.colors.text)
                    .lineLimit(1)
                    .minimumScaleFactor(TextScale.compact)
            }
        }
        .padding(.horizontal, Spacing.s)
        .padding(.vertical, Spacing.m)
        .glassTile()
        .accessibilityElement(children: .combine)
        .accessibilityValue(valueText == nil && statusText == nil ? AppFormat.noData : "")
    }

    // MARK: - Карточка

    private var compactBody: some View {
        VStack(alignment: isSolid ? .center : .leading, spacing: isSolid ? Spacing.xs : Spacing.m) {
            header
            value
            if let statusText {
                Text(statusText)
                    .textStyle(isSolid ? .tileUnit : .captionStrong)
                    .foregroundStyle(tone.colors.text)
                    .multilineTextAlignment(isSolid ? .center : .leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if showsSparkline {
                Spacer(minLength: Spacing.xs)
                Sparkline(values: series, color: kind.color, style: sparklineStyle)
            }
            if valueText == nil {
                emptyAction
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var header: some View {
        if isSolid {
            HStack(spacing: Spacing.s) {
                Image(systemName: kind.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Size.cardIcon, height: Size.cardIcon)
                    .foregroundStyle(kind.color)
                    .accessibilityHidden(true)
                Text(kind.title)
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
            }
        } else {
            HStack(spacing: Spacing.s) {
                Image(systemName: kind.iconName)
                    .textStyle(.captionStrong)
                    .foregroundStyle(kind.color)
                    .frame(width: Size.metricIcon, height: Size.metricIcon)
                    .background(AppColor.fill, in: Circle())
                    .accessibilityHidden(true)
                Text(kind.title)
                    .textStyle(.label)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder
    private var value: some View {
        if isSolid {
            VStack(spacing: Spacing.xs) {
                Text(valueText ?? AppFormat.dash)
                    .textStyle(.cardValue)
                    .foregroundStyle(valueText == nil ? AppColor.textTertiary : AppColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(TextScale.metric)
                    .accessibilityLabel(valueText.map { Text($0) } ?? Text(AppFormat.noData))
                Text(unit)
                    .textStyle(.tileUnit)
                    .foregroundStyle(AppColor.neutral.text)
            }
        } else {
            MetricValueText(
                value: valueText ?? AppFormat.dash,
                unit: unit,
                style: .metricCardSmall,
                isPlaceholder: valueText == nil
            )
        }
    }

    private var sparklineStyle: Sparkline.Style {
        switch kind {
        case .pulse: return .marker
        case .weight: return .forecast
        case .pressure, .glucose: return .line
        }
    }

    /// Кнопка пустой карточки. Без действия (экрана ввода показателя нет) она выключена и объяснена подписью.
    private var emptyAction: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            PrimaryButton(title: "Добавить измерение", style: .outline, isEnabled: onAdd != nil, action: onAdd ?? {})
                .accessibilityIdentifier("metric-empty-add-\(kind.rawValue)")
            if onAdd == nil {
                Text("Ввод этого показателя пока недоступен")
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func surfaced<Content: View>(_ content: Content) -> some View {
        switch surface {
        case .glass:
            content.glassCard(radius: Radius.card, insets: CardInsets.compact)
        case .solid:
            let shape = RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
            content
                .padding(Spacing.l)
                .frame(maxWidth: .infinity)
                .background { shape.fill(AppColor.solidCardFill) }
                .overlay { shape.strokeBorder(AppColor.solidCardStroke, lineWidth: Size.hairline) }
        }
    }
}

#Preview("MetricCard: плитки") {
    VStack(spacing: Spacing.l) {
        HStack(spacing: Spacing.tileGap) {
            MetricCard(kind: .pressure, valueText: "122/79", unit: AppUnit.pressure, statusText: "Норма", tone: .positive, layout: .tile)
            MetricCard(kind: .pulse, valueText: "68", unit: AppUnit.pulse, layout: .tile)
            MetricCard(kind: .weight, valueText: "74,2", unit: AppUnit.weight, layout: .tile)
        }
        HStack(spacing: Spacing.tileGap) {
            MetricCard(kind: .pressure, valueText: "134/86", unit: AppUnit.pressure, statusText: "Повышенное", tone: .caution, layout: .tile)
            MetricCard(kind: .pressure, valueText: "148/94", unit: AppUnit.pressure, statusText: "Высокое", tone: .critical, layout: .tile)
            MetricCard(kind: .weight, valueText: nil, unit: AppUnit.weight, layout: .tile)
        }
        HStack(spacing: Spacing.tileGap) {
            MetricCard(kind: .pressure, valueText: nil, unit: AppUnit.pressure, statusText: AppFormat.noData, layout: .tile)
            MetricCard(kind: .pulse, valueText: nil, unit: AppUnit.pulse, layout: .tile)
            SkeletonTile()
        }
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.homeBackground)
}

#Preview("MetricCard: solid, тона статуса") {
    VStack(spacing: Spacing.m) {
        HStack(alignment: .top, spacing: Spacing.m) {
            MetricCard(
                kind: .pulse, valueText: "68", unit: AppUnit.pulse, statusText: "В покое", tone: .positive,
                series: [66, 68, 65, 70, 67], surface: .solid
            )
            MetricCard(
                kind: .weight, valueText: "74,2", unit: AppUnit.weight, statusText: "−0,4 кг за 2 недели", tone: .positive,
                series: [74.6, 74.4, 74.2], surface: .solid, showsSparkline: false
            )
        }
        .fixedSize(horizontal: false, vertical: true)
        HStack(alignment: .top, spacing: Spacing.m) {
            MetricCard(
                kind: .pulse, valueText: "104", unit: AppUnit.pulse, statusText: "Повышен", tone: .caution,
                series: [90, 98, 104], surface: .solid
            )
            MetricCard(
                kind: .pulse, valueText: "132", unit: AppUnit.pulse, statusText: "Высокий", tone: .critical,
                series: [100, 120, 132], surface: .solid
            )
        }
        .fixedSize(horizontal: false, vertical: true)
        MetricCard(
            kind: .pulse, valueText: nil, unit: AppUnit.pulse, statusText: "Измерений пока нет", tone: .neutral,
            surface: .solid
        )
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.homeBackground)
}

#Preview("MetricCard: glass") {
    HStack(alignment: .top, spacing: Spacing.m) {
        MetricCard(
            kind: .pulse, valueText: "68", unit: AppUnit.pulse, statusText: "В покое", tone: .neutral,
            series: [66, 68, 65, 70, 67]
        )
        MetricCard(
            kind: .weight, valueText: "74,2", unit: AppUnit.weight, statusText: "−0,4 кг за 2 недели", tone: .neutral,
            series: [74.6, 74.4, 74.2]
        )
    }
    .fixedSize(horizontal: false, vertical: true)
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("MetricCard: пусто (с действием и без)") {
    VStack(spacing: Spacing.l) {
        MetricCard(
            kind: .glucose, valueText: nil, unit: AppUnit.glucose,
            statusText: "Измерений пока нет", tone: .neutral, onAdd: {}
        )
        MetricCard(kind: .glucose, valueText: nil, unit: AppUnit.glucose, statusText: "Измерений пока нет", tone: .neutral)
    }
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
