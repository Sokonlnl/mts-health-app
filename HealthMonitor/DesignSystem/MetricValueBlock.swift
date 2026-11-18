import SwiftUI

/// Крупное значение показателя с единицей и чипом статуса зоны (`StatusPill` `.tinted`).
/// Общий блок большой карточки главного экрана (`.card`, слева, значение и единица на базовой линии) и верхнего блока
/// экрана давления (`.hero`, по центру, значение над единицей, анимированная смена значения).
/// Нет данных: `isPlaceholder` (значение textTertiary). Идентификаторы и подпись VoiceOver задаёт вызывающий,
/// когда блок читается отдельно (в `.card` карточка сама одна связка).
struct MetricValueBlock: View {
    enum Style {
        case card
        case hero
    }

    let valueText: String
    let unit: String
    var statusText: String?
    var tone: StatusTone = .neutral
    var isPlaceholder = false
    var style: Style = .card
    var valueAccessibilityText: String?
    var valueIdentifier: String?
    var statusIdentifier: String?

    var body: some View {
        switch style {
        case .card:
            VStack(alignment: .leading, spacing: Spacing.m) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.m) { value; cardUnit }
                    VStack(alignment: .leading, spacing: Spacing.xs) { value; cardUnit }
                }
                pill
            }
        case .hero:
            // Значение, единица и чип с одинаковым зазором 4 pt (Figma 86:123). Значение с единицей читаются одной связкой.
            VStack(spacing: Spacing.xs) {
                VStack(spacing: Spacing.xs) {
                    value
                    heroUnit
                }
                .contentSwap("\(valueText)|\(unit)")
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(valueAccessibilityText ?? "\(valueText) \(unit)")
                .optionalIdentifier(valueIdentifier)
                pill
                    .contentSwap(statusText ?? "")
                    .optionalIdentifier(statusIdentifier)
            }
        }
    }

    private var value: some View {
        Text(valueText)
            .textStyle(.heroValue)
            .foregroundStyle(isPlaceholder ? AppColor.textTertiary : AppColor.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(TextScale.metric)
    }

    private var cardUnit: some View {
        Text(unit)
            .textStyle(.unitLabel)
            .foregroundStyle(AppColor.neutral.text)
            .lineLimit(2)
    }

    private var heroUnit: some View {
        Text(unit)
            .textStyle(.unitLabel)
            .foregroundStyle(AppColor.neutral.text)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var pill: some View {
        if let statusText {
            StatusPill(text: statusText, tone: tone, style: .tinted)
        }
    }
}

private extension View {
    @ViewBuilder
    func optionalIdentifier(_ identifier: String?) -> some View {
        if let identifier {
            accessibilityIdentifier(identifier)
        } else {
            self
        }
    }
}

#Preview("MetricValueBlock: карточка, зоны и нет данных") {
    VStack(alignment: .leading, spacing: Spacing.xl) {
        MetricValueBlock(valueText: "122/79", unit: AppUnit.pressure, statusText: "Норма", tone: .positive)
        MetricValueBlock(valueText: "134/86", unit: AppUnit.pressure, statusText: "Повышенное", tone: .caution)
        MetricValueBlock(valueText: "148/94", unit: AppUnit.pressure, statusText: "Высокое", tone: .critical)
        MetricValueBlock(
            valueText: AppFormat.emptyPressureValue, unit: AppUnit.pressure, statusText: AppFormat.noData, isPlaceholder: true
        )
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("MetricValueBlock: верхний блок, данные и нет данных") {
    VStack(spacing: Spacing.xl) {
        MetricValueBlock(
            valueText: "122/79", unit: AppFormat.pressureUnit(pulse: 68), statusText: "Норма", tone: .positive, style: .hero
        )
        MetricValueBlock(
            valueText: AppFormat.emptyPressureValue, unit: AppUnit.pressure, statusText: AppFormat.noData,
            isPlaceholder: true, style: .hero
        )
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
