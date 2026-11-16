import SwiftUI

/// Карточка последнего измерения: значение, статус, пульс, диапазон и среднее за период.
struct PressureLatestCard: View {
    let latest: PressureMeasurement?
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
                if let latest {
                    StatusPill(text: latest.zone.title, tone: latest.zone.tone)
                        .accessibilityIdentifier("pressure-latest-status")
                } else {
                    StatusPill(text: "Нет данных", tone: .neutral)
                }
            }
            HStack(alignment: .firstTextBaseline, spacing: Spacing.s) {
                Text(valueText)
                    .textStyle(.metricHero)
                    .foregroundStyle(latest == nil ? AppColor.textTertiary : AppColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .accessibilityIdentifier("pressure-latest-value")
                Text("мм рт. ст.")
                    .textStyle(.label)
                    .foregroundStyle(AppColor.textSecondary)
            }
            HStack {
                Text("Пульс \(pulseText)")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textSecondary)
                Spacer(minLength: Spacing.s)
                Text(dateText)
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Rectangle()
                .fill(AppColor.border)
                .frame(height: Size.hairline)
                .accessibilityHidden(true)
            HStack(alignment: .top, spacing: Spacing.l) {
                LabeledValue(title: "Диапазон за период", value: rangeText)
                LabeledValue(title: "Среднее за период", value: averageText)
            }
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(radius: Radius.hero)
    }

    private var valueText: String {
        guard let latest else { return "\(AppFormat.dash)/\(AppFormat.dash)" }
        return AppFormat.pressureValue(latest.systolic, latest.diastolic)
    }
}

/// Карточка «Почему такой статус».
struct PressureWhyCard: View {
    let zone: PressureZone?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Почему такой статус")
                .textStyle(.headline)
                .foregroundStyle(AppColor.textPrimary)
            Text(zone?.explanation ?? "Добавьте измерение, чтобы увидеть пояснение по зоне.")
                .textStyle(.body)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(PressureZone.disclaimer)
                .textStyle(.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

/// История измерений: «значение · пульс», время и контекст, статус.
struct PressureHistoryList: View {
    let items: [PressureMeasurement]
    let dateText: (PressureMeasurement) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("История")
                .textStyle(.headline)
                .foregroundStyle(AppColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if items.isEmpty {
                Text("За выбранный период измерений нет.")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(Spacing.l)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        if index > 0 {
                            Rectangle()
                                .fill(AppColor.border)
                                .frame(height: Size.hairline)
                                .accessibilityHidden(true)
                        }
                        row(item)
                    }
                }
                .padding(.horizontal, Spacing.l)
                .cardStyle()
                .accessibilityIdentifier("pressure-history")
            }
        }
    }

    private func row(_ item: PressureMeasurement) -> some View {
        HStack(spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title(item))
                    .textStyle(.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)
                Text(subtitle(item))
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer(minLength: Spacing.s)
            StatusPill(text: item.zone.title, tone: item.zone.tone)
        }
        .padding(.vertical, Spacing.m)
        .frame(minHeight: Spacing.minTapTarget)
        .accessibilityElement(children: .combine)
    }

    private func title(_ item: PressureMeasurement) -> String {
        let value = AppFormat.pressureValue(item.systolic, item.diastolic)
        guard let pulse = item.pulse else { return value }
        return "\(value) · \(pulse)"
    }

    private func subtitle(_ item: PressureMeasurement) -> String {
        guard let context = item.context else { return dateText(item) }
        return "\(dateText(item)) · \(context.title)"
    }
}

#Preview("Pressure cards: данные") {
    let sample = PressureMeasurement(
        id: "preview", date: Date(), systolic: 132, diastolic: 86, pulse: 70, context: .morning
    )
    return ScrollView {
        VStack(spacing: Spacing.l) {
            PressureLatestCard(
                latest: sample, dateText: "Сегодня, 08:10", pulseText: "70 уд/мин",
                rangeText: "118–136 / 74–88", averageText: "125/80"
            )
            PressureWhyCard(zone: sample.zone)
            PressureHistoryList(items: [sample, sample], dateText: { _ in "Сегодня, 08:10" })
        }
        .padding(Spacing.screenMargin)
    }
    .background(AppColor.background)
}

#Preview("Pressure cards: пусто") {
    VStack(spacing: Spacing.l) {
        PressureLatestCard(
            latest: nil, dateText: "Нет измерений", pulseText: AppFormat.dash,
            rangeText: AppFormat.dash, averageText: AppFormat.dash
        )
        PressureWhyCard(zone: nil)
        PressureHistoryList(items: [], dateText: { _ in "" })
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
