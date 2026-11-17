import SwiftUI

/// Форма Aura 240 pt с последним измерением, под ней статус-пилюля и строка с датой.
struct PressureHero: View {
    let state: HealthState
    let valueText: String
    let unitText: String
    let statusText: String
    let subtitle: String
    let accessibilityText: String

    var body: some View {
        VStack(spacing: Spacing.m) {
            AuraOrb(palette: state.palette, diameter: Size.orbPressure) {
                AuraOrbCenter(
                    caption: "Последнее измерение",
                    value: valueText,
                    unit: unitText,
                    valueStyle: .heroValueCompact,
                    isPlaceholder: state == .noData,
                    accessibilityText: accessibilityText,
                    valueIdentifier: "pressure-latest-value",
                    contentKey: "\(valueText)|\(unitText)"
                )
            }
            StatusPill(text: statusText, tone: state.tone)
                .contentSwap(statusText)
                .accessibilityIdentifier("pressure-latest-status")
            Text(subtitle)
                .textStyle(.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Карточка «Почему такой статус»: пояснение, три плашки с границами зон, оговорка.
struct PressureWhyCard: View {
    let zone: PressureZone?
    let explanation: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "Почему такой статус", isCompact: true)
            Text(explanation)
                .textStyle(.body)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .top, spacing: Spacing.s) {
                ForEach(PressureZone.allCases, id: \.self) { item in
                    plate(item)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            Text(PressureZone.disclaimer)
                .textStyle(.caption)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .glassCard()
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("pressure-why")
    }

    private func plate(_ item: PressureZone) -> some View {
        let isCurrent = item == zone
        let shape = RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(item.title)
                .textStyle(.captionStrong)
                .foregroundStyle(item.tone.colors.text)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.compact)
            Text(item.thresholdText)
                .textStyle(.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(Spacing.s)
        .background(AppColor.fill, in: shape)
        .overlay {
            shape.strokeBorder(
                isCurrent ? item.tone.colors.text : AppColor.glassStroke,
                lineWidth: isCurrent ? Size.focusRing : Size.hairline
            )
        }
    }
}

/// История измерений: значение, дата и время, справа точка и статус цветом. Строки готовит ViewModel.
struct PressureHistoryList: View {
    let rows: [PressureHistoryRow]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "История", isCompact: true)
            if rows.isEmpty {
                Text("За выбранный период измерений нет.")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .glassCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                        if index > 0 {
                            Hairline()
                        }
                        rowView(row)
                    }
                }
                .glassCard(insets: CardInsets.list)
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
            StatusDotLabel(text: row.zone.title, tone: row.zone.tone)
        }
        .padding(.vertical, Spacing.s)
        .frame(minHeight: Size.historyRow)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("history-row-\(row.id)")
    }
}

private enum PreviewSamples {
    static let rows = [
        PressureHistoryRow(id: "a", title: "132/86 · 70", subtitle: "Сегодня, 08:10 · Утро", zone: .elevated),
        PressureHistoryRow(id: "b", title: "118/76 · 66", subtitle: "Вчера, 21:30", zone: .normal)
    ]
}

private func heroPreview(_ state: HealthState, value: String, status: String) -> some View {
    PressureHero(
        state: state, valueText: value, unitText: "\(AppUnit.pressure) · пульс 68", statusText: status,
        subtitle: "Сегодня, 08:10 · Утро", accessibilityText: "Последнее измерение \(value), \(status)"
    )
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("PressureHero: норма") {
    heroPreview(.normal, value: "122/79", status: "Норма")
}

#Preview("PressureHero: повышенное") {
    heroPreview(.elevated, value: "134/86", status: "Повышенное")
}

#Preview("PressureHero: высокое") {
    heroPreview(.high, value: "148/94", status: "Высокое")
}

#Preview("PressureHero: нет данных") {
    heroPreview(.noData, value: AppFormat.emptyPressureValue, status: AppFormat.noData)
}

#Preview("Pressure cards: данные") {
    ScrollView {
        VStack(spacing: Spacing.l) {
            PressureWhyCard(zone: .elevated, explanation: PressureZone.elevated.explanation)
            PressureHistoryList(rows: PreviewSamples.rows)
        }
        .padding(Spacing.screenMargin)
    }
    .background(AppColor.background)
}

#Preview("Pressure cards: пусто") {
    VStack(spacing: Spacing.l) {
        PressureWhyCard(zone: nil, explanation: "Добавьте измерение")
        PressureHistoryList(rows: [])
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
