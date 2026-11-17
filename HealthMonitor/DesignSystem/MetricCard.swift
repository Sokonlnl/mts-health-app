import SwiftUI

/// Карточка показателя на главном экране.
///
/// Раскладка (`layout`):
/// - `.tile`: стеклянная плитка бенто (подпись, значение 38, единица, статус зоны текстом), без иконки и графика.
///   Заполняет высоту, которую отдаёт `BentoGrid`.
/// - `.compact`: карточка с иконкой, значением, статусом и мини-графиком.
///
/// Поверхность (`surface`) у `.compact`: `.glass` (стекло, радиус 28) или `.solid` (#202020, контур #383838,
/// радиус 32, иконка и название слева сверху, остальное по центру, график 141×44). Цвет статуса задаёт `tone`.
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
    /// Стиль мини-графика (приходит из модели карточки).
    var sparklineStyle: Sparkline.Style = .line
    /// Готовая подпись справа от значения (из модели). `nil`: единица.
    var valueCaption: String?

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
                .foregroundStyle(AppColor.textSecondary)
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
        VStack(alignment: isSolid ? .center : .leading, spacing: isSolid ? Spacing.m : Spacing.s) {
            header
            value
            if let statusText, valueText != nil || isSolid {
                Text(statusText)
                    .textStyle(isSolid ? .tileUnit : .captionStrong)
                    .foregroundStyle(tone.colors.text)
                    .multilineTextAlignment(isSolid ? .center : .leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: isSolid ? Spacing.m : Spacing.xs)
            Sparkline(
                values: series, color: kind.color, style: sparklineStyle,
                height: isSolid ? Size.sparklineSolidHeight : Size.sparklineHeight
            )
            .frame(maxWidth: isSolid ? Size.sparklineSolidWidth : .infinity)
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
                Spacer(minLength: 0)
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
                    .textStyle(.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)
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
                    .foregroundStyle(AppColor.textSecondary)
            }
        } else {
            MetricValueText(
                value: valueText ?? AppFormat.dash,
                unit: valueCaption ?? unit,
                style: .metricCardSmall,
                isPlaceholder: valueText == nil
            )
        }
    }

    /// Кнопка пустой карточки. Экрана ввода показателя нет: она всегда выключена и объяснена подписью.
    private var emptyAction: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            PrimaryButton(title: AppFormat.addMeasurement, style: .outline, isEnabled: false, action: {})
                .accessibilityIdentifier("metric-empty-add-\(kind.rawValue)")
            Text(AppFormat.inputUnavailable)
                .textStyle(.caption)
                .foregroundStyle(AppColor.textSecondary)
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
                .padding(Spacing.xl)
                .frame(maxWidth: .infinity)
                .background { shape.fill(AppColor.solidCardFill) }
                .overlay { shape.strokeBorder(AppColor.solidCardStroke, lineWidth: Size.hairline) }
        }
    }
}

#Preview("MetricCard: плитки") {
    ScrollView {
        VStack(spacing: Spacing.l) {
            BentoGrid {
                MetricCard(
                    kind: .pressure, valueText: "122/79", unit: AppUnit.pressure,
                    statusText: "Норма", tone: .positive, layout: .tile
                )
            } side: {
                MetricCard(kind: .pulse, valueText: "68", unit: AppUnit.pulse, layout: .tile)
                MetricCard(kind: .weight, valueText: "74,2", unit: AppUnit.weight, layout: .tile)
            }
            BentoGrid {
                MetricCard(
                    kind: .pressure, valueText: "134/86", unit: AppUnit.pressure,
                    statusText: "Повышенное", tone: .caution, layout: .tile
                )
            } side: {
                MetricCard(kind: .pulse, valueText: nil, unit: AppUnit.pulse, layout: .tile)
                MetricCard(kind: .weight, valueText: nil, unit: AppUnit.weight, layout: .tile)
            }
            BentoGrid {
                MetricCard(
                    kind: .pressure, valueText: "148/94", unit: AppUnit.pressure,
                    statusText: "Высокое", tone: .critical, layout: .tile
                )
            } side: {
                SkeletonTile()
                SkeletonTile()
            }
            BentoGrid {
                MetricCard(kind: .pressure, valueText: nil, unit: AppUnit.pressure, statusText: AppFormat.noData, layout: .tile)
            } side: {
                MetricCard(kind: .pulse, valueText: nil, unit: AppUnit.pulse, layout: .tile)
                MetricCard(kind: .weight, valueText: nil, unit: AppUnit.weight, layout: .tile)
            }
        }
        .padding(Spacing.screenMargin)
    }
    .background(AppColor.homeBackground)
}

#Preview("MetricCard: solid, тона статуса") {
    VStack(spacing: Spacing.m) {
        MetricCard(
            kind: .pulse, valueText: "68", unit: AppUnit.pulse, statusText: AppFormat.restingStatus, tone: .positive,
            series: [66, 68, 65, 70, 67], surface: .solid
        )
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
            kind: .pulse, valueText: nil, unit: AppUnit.pulse, statusText: AppFormat.noMeasurementsYet, tone: .neutral,
            surface: .solid
        )
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.homeBackground)
}

#Preview("MetricCard: glass") {
    HStack(alignment: .top, spacing: Spacing.m) {
        MetricCard(
            kind: .pulse, valueText: "68", unit: AppUnit.pulse, statusText: AppFormat.restingStatus, tone: .neutral,
            series: [66, 68, 65, 70, 67]
        )
        MetricCard(
            kind: .weight, valueText: "74,2", unit: AppUnit.weight, statusText: AppFormat.lastValue, tone: .neutral,
            series: [74.6, 74.4, 74.2]
        )
    }
    .fixedSize(horizontal: false, vertical: true)
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("MetricCard: пусто (кнопка выключена)") {
    VStack(spacing: Spacing.l) {
        MetricCard(
            kind: .glucose, valueText: nil, unit: AppUnit.glucose,
            statusText: AppFormat.noMeasurementsYet, tone: .neutral,
            valueCaption: AppUnit.glucose + " · " + AppFormat.noMeasurementsYet.lowercased()
        )
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
