import SwiftUI

/// Карточка последнего измерения: значение, статус, пульс, диапазон и среднее за период.
/// Текст значения готовит ViewModel; `zone == nil` означает пустое состояние.
struct PressureLatestCard: View {
    let zone: PressureZone?
    let valueText: String
    let dateText: String
    let pulseText: String
    let rangeText: String
    let averageText: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                Text("Последнее измерение")
                    .textStyle(.label)
                    .foregroundStyle(AppColor.textSecondary)
                Spacer(minLength: Spacing.s)
                if let zone {
                    StatusPill(text: zone.title, tone: zone.tone)
                        .accessibilityIdentifier("pressure-latest-status")
                } else {
                    StatusPill(text: AppFormat.noData, tone: .neutral)
                }
            }
            MetricValueText(
                value: valueText,
                unit: AppUnit.pressure,
                style: .metricHero,
                isPlaceholder: zone == nil,
                spacing: Spacing.s,
                valueIdentifier: "pressure-latest-value"
            )
            HStack {
                Text("Пульс \(pulseText)")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textSecondary)
                Spacer(minLength: Spacing.s)
                Text(dateText)
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Hairline()
            HStack(alignment: .top, spacing: Spacing.l) {
                LabeledValue(title: "Диапазон за период", value: rangeText)
                LabeledValue(title: "Среднее за период", value: averageText)
            }
        }
        .cardStyle(radius: Radius.hero)
    }
}

/// Карточка «Почему такой статус».
struct PressureWhyCard: View {
    let zone: PressureZone?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Почему такой статус")
            Text(zone?.explanation ?? "Добавьте измерение, чтобы увидеть пояснение по зоне.")
                .textStyle(.body)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(PressureZone.disclaimer)
                .textStyle(.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

/// История измерений: «значение · пульс», время и контекст, статус. Строки готовит ViewModel.
struct PressureHistoryList: View {
    let rows: [PressureHistoryRow]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "История")
            if rows.isEmpty {
                Text("За выбранный период измерений нет.")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .cardStyle()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                        if index > 0 {
                            Hairline()
                        }
                        rowView(row)
                    }
                }
                .cardStyle(insets: CardInsets.list)
                .accessibilityIdentifier("pressure-history")
            }
        }
    }

    private func rowView(_ row: PressureHistoryRow) -> some View {
        HStack(spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(row.title)
                    .textStyle(.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)
                Text(row.subtitle)
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer(minLength: Spacing.s)
            StatusPill(text: row.zone.title, tone: row.zone.tone)
        }
        .padding(.vertical, Spacing.m)
        .frame(minHeight: Spacing.minTapTarget)
        .accessibilityElement(children: .combine)
    }
}

private enum PreviewSamples {
    static let rows = [
        PressureHistoryRow(id: "a", title: "132/86 · 70", subtitle: "Сегодня, 08:10 · Утро", zone: .elevated),
        PressureHistoryRow(id: "b", title: "118/76 · 66", subtitle: "Вчера, 21:30", zone: .normal)
    ]
}

private func latestCard(zone: PressureZone, value: String) -> some View {
    PressureLatestCard(
        zone: zone, valueText: value, dateText: "Сегодня, 08:10", pulseText: "70 \(AppUnit.pulse)",
        rangeText: "118–136 / 74–88", averageText: "125/80"
    )
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("PressureLatestCard: норма") {
    latestCard(zone: .normal, value: "118/76")
}

#Preview("PressureLatestCard: повышенное") {
    latestCard(zone: .elevated, value: "134/86")
}

#Preview("PressureLatestCard: высокое") {
    latestCard(zone: .high, value: "148/94")
}

#Preview("PressureLatestCard: пусто") {
    PressureLatestCard(
        zone: nil, valueText: AppFormat.emptyPressureValue, dateText: AppFormat.noMeasurements,
        pulseText: AppFormat.dash, rangeText: AppFormat.dash, averageText: AppFormat.dash
    )
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("Pressure cards: данные") {
    ScrollView {
        VStack(spacing: Spacing.l) {
            PressureWhyCard(zone: .elevated)
            PressureHistoryList(rows: PreviewSamples.rows)
        }
        .padding(Spacing.screenMargin)
    }
    .background(AppColor.background)
}

#Preview("Pressure cards: пусто") {
    VStack(spacing: Spacing.l) {
        PressureWhyCard(zone: nil)
        PressureHistoryList(rows: [])
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
