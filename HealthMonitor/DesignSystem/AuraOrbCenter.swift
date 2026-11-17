import SwiftUI

/// Содержимое по центру формы Aura: подпись, значение, единица, статус-пилюля.
/// Без тёмной подложки и стеклянного круга: читаемость даёт тень текста и непрозрачность слоёв формы до 62%.
/// VoiceOver читает всё одной связкой (`accessibilityText`), форма скрыта.
struct AuraOrbCenter: View {
    let caption: String?
    let value: String
    let unit: String
    var valueStyle: AppTextStyle = .heroValue
    var statusText: String?
    var tone: StatusTone = .neutral
    /// Прочерк вместо значения (декоративный, рядом читаемая подпись).
    var isPlaceholder = false
    let accessibilityText: String
    var valueIdentifier = ""
    /// Ключ анимации `contentSwap`: при смене текст значения появляется заново.
    let contentKey: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            if let caption {
                Text(caption)
                    .textStyle(.label)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
            }
            Text(value)
                .textStyle(valueStyle)
                .foregroundStyle(isPlaceholder ? AppColor.textTertiary : AppColor.textPrimary)
                .shadow(color: AppColor.textShadow, radius: 12)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.metric)
            Text(unit)
                .textStyle(.label)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.compact)
            if let statusText {
                StatusPill(text: statusText, tone: tone)
                    .padding(.top, Spacing.xs)
            }
        }
        .contentSwap(contentKey)
        .padding(.horizontal, Spacing.xl)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityIdentifier(valueIdentifier)
    }
}

private struct CenterPreview: View {
    let palette: AuraPalette
    let value: String
    let status: String
    let tone: StatusTone
    var isPlaceholder = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            AuraOrb(palette: palette, diameter: Size.orbPressure) {
                AuraOrbCenter(
                    caption: "Давление",
                    value: value,
                    unit: AppUnit.pressure,
                    statusText: status,
                    tone: tone,
                    isPlaceholder: isPlaceholder,
                    accessibilityText: "Давление \(value), \(status)",
                    contentKey: value
                )
            }
        }
    }
}

#Preview("AuraOrbCenter: норма") {
    CenterPreview(palette: .normal, value: "122/79", status: "Норма", tone: .positive)
}

#Preview("AuraOrbCenter: повышенное") {
    CenterPreview(palette: .elevated, value: "134/86", status: "Повышенное", tone: .caution)
}

#Preview("AuraOrbCenter: высокое") {
    CenterPreview(palette: .high, value: "148/94", status: "Высокое", tone: .critical)
}

#Preview("AuraOrbCenter: нет данных") {
    CenterPreview(palette: .noData, value: AppFormat.emptyPressureValue, status: AppFormat.noData, tone: .neutral, isPlaceholder: true)
}
