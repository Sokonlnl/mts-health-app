import SwiftUI

/// Карточка показателя на главном экране (Figma 63:25250).
///
/// Раскладка (`layout`):
/// - `.large`: большая стеклянная карточка давления 358×258, радиус 48, отступ 24: иконка и подпись, значение 59,7 с единицей,
///   чип статуса зоны (`StatusPill` `.tinted`) и сердце `HeartGlow` цвета зоны в правом нижнем углу.
/// - `.small`: малая карточка (вес, глюкоза) 174,5×166, радиус 33,4, отступ 16: иконка и подпись, значение 24 с единицей
///   и мини-шкала внизу (`MetricGauge`).
///
/// Пустое состояние: `isPlaceholder` (прочерк textTertiary, рядом читаемая подпись). Для VoiceOver карточка одна
/// связка с готовой подписью (`accessibilityText`); идентификатор задаёт вызывающий на самой карточке.
struct MetricCard: View {
    enum Layout {
        case large
        case small
    }

    let kind: MetricKind
    let valueText: String
    var isPlaceholder = false
    /// Единица или (в пустой карточке) готовая подпись «единица · статус».
    let unit: String
    var statusText: String?
    var tone: StatusTone = .neutral
    var layout: Layout = .small
    var gauge: MetricGauge.Style?
    var gaugePosition: Double?
    /// Ритм сердцебиения декоративного сердца (`.large`). `nil`: сердце неподвижно.
    var rhythm: HeartbeatRhythm?
    let accessibilityText: String

    var body: some View {
        Group {
            switch layout {
            case .large:
                largeBody
            case .small:
                smallBody
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var valueColor: Color { isPlaceholder ? AppColor.textTertiary : AppColor.textPrimary }

    private func header(iconSize: CGFloat, label: AppTextStyle) -> some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: kind.iconName)
                .textStyle(.cardIcon)
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(AppColor.textDim)
            Text(kind.title)
                .textStyle(label)
                .foregroundStyle(AppColor.textDim)
                .lineLimit(1)
        }
    }

    // MARK: - Большая

    private var largeShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.heroCard, style: .continuous)
    }

    private var largeBody: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            header(iconSize: Size.cardIconLarge, label: .cardLabel)
            MetricValueBlock(
                valueText: valueText, unit: unit, statusText: statusText, tone: tone, isPlaceholder: isPlaceholder
            )
            Spacer(minLength: 0)
        }
        .padding(Spacing.xxl)
        .frame(maxWidth: .infinity, minHeight: Size.pressureCardHeight, alignment: .topLeading)
        .background {
            ZStack {
                GlassSurface(shape: largeShape, style: .hero)
                HeartGlow(color: tone.colors.text, rhythm: rhythm).clipShape(largeShape)
            }
        }
    }

    // MARK: - Малая

    private var smallBody: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            header(iconSize: Size.cardIconLarge, label: .smallCardLabel)
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text(valueText)
                    .textStyle(.smallCardValue)
                    .foregroundStyle(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(TextScale.metric)
                Text(unit)
                    .textStyle(.unitLabel)
                    .foregroundStyle(AppColor.neutral.text)
                    .lineLimit(2)
            }
            Spacer(minLength: Spacing.xs)
            if let gauge {
                MetricGauge(style: gauge, position: gaugePosition)
                    .frame(maxWidth: .infinity, alignment: .center)
                    // Дуга идёт на всю ширину плитки (как в Figma), полосы остаются в полях.
                    .padding(.horizontal, gauge == .arc ? -Spacing.l : 0)
            }
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, minHeight: Size.smallCardHeight, maxHeight: .infinity, alignment: .topLeading)
        .glassBackground(in: RoundedRectangle(cornerRadius: Radius.tile, style: .continuous), style: .flat)
        .clipShape(RoundedRectangle(cornerRadius: Radius.tile, style: .continuous))
    }
}

#Preview("MetricCard: большая (норма, повышенное, высокое, нет данных)") {
    ScrollView {
        VStack(spacing: Spacing.columnGap) {
            MetricCard(
                kind: .pressure, valueText: "122/79", unit: AppUnit.pressure, statusText: "Норма", tone: .positive,
                layout: .large, accessibilityText: "Давление 122 на 79, норма"
            )
            MetricCard(
                kind: .pressure, valueText: "134/86", unit: AppUnit.pressure, statusText: "Повышенное", tone: .caution,
                layout: .large, accessibilityText: "Давление 134 на 86, повышенное"
            )
            MetricCard(
                kind: .pressure, valueText: "148/94", unit: AppUnit.pressure, statusText: "Высокое", tone: .critical,
                layout: .large, accessibilityText: "Давление 148 на 94, высокое"
            )
            MetricCard(
                kind: .pressure, valueText: AppFormat.emptyPressureValue, isPlaceholder: true, unit: AppUnit.pressure,
                statusText: AppFormat.noData, tone: .neutral, layout: .large, accessibilityText: "Давление: нет данных"
            )
        }
        .padding(Spacing.screenMargin)
    }
    .background(AppColor.background)
}

#Preview("MetricCard: малые (данные и пусто)") {
    VStack(spacing: Spacing.columnGap) {
        HStack(spacing: Spacing.tileGap) {
            MetricCard(
                kind: .weight, valueText: "72,4", unit: AppUnit.weight, gauge: .bands, gaugePosition: 0.45,
                accessibilityText: "Вес 72,4 кг"
            )
            MetricCard(
                kind: .glucose, valueText: "5,4", unit: AppUnit.glucose, gauge: .arc, gaugePosition: 0.4,
                accessibilityText: "Глюкоза 5,4 ммоль/л"
            )
        }
        .fixedSize(horizontal: false, vertical: true)
        HStack(spacing: Spacing.tileGap) {
            MetricCard(
                kind: .weight, valueText: AppFormat.dash, isPlaceholder: true,
                unit: AppFormat.unitCaption(AppUnit.weight, status: AppFormat.noMeasurementsYet), accessibilityText: "Вес: нет данных"
            )
            MetricCard(
                kind: .glucose, valueText: AppFormat.dash, isPlaceholder: true,
                unit: AppFormat.unitCaption(AppUnit.glucose, status: AppFormat.noMeasurementsYet), accessibilityText: "Глюкоза: нет данных"
            )
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

// У карточки показателя loading и error показываются на уровне экрана: скелетон и сообщение об ошибке.
#Preview("MetricCard: loading") {
    VStack(spacing: Spacing.columnGap) {
        SkeletonCard(identifier: "skeleton-card", minHeight: Size.pressureCardHeight, radius: Radius.heroCard)
        SkeletonCard(minHeight: Size.smallCardHeight, radius: Radius.tile)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("MetricCard: error") {
    ErrorStateView(message: "Сервис временно недоступен. Проверьте соединение и повторите попытку.", retry: {})
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}

#Preview("MetricCard: большая, сердце бьётся 68 уд/мин и без движения") {
    VStack(spacing: Spacing.columnGap) {
        MetricCard(
            kind: .pressure, valueText: "122/79", unit: AppUnit.pressure, statusText: "Норма", tone: .positive,
            layout: .large, rhythm: HeartbeatRhythm(pulse: 68), accessibilityText: "Давление 122 на 79, норма"
        )
        MetricCard(
            kind: .pressure, valueText: "122/79", unit: AppUnit.pressure, statusText: "Норма", tone: .positive,
            layout: .large, rhythm: HeartbeatRhythm(pulse: 68), accessibilityText: "Давление 122 на 79, норма"
        )
        .environment(\.isAmbientMotionEnabled, false)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
