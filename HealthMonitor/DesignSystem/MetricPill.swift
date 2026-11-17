import SwiftUI

/// Пилюля показателя в верхнем ряду главного экрана: круг 56 со значением и подпись снизу.
/// Цель нажатия 68 x 84. Выбранная получает контур цвета статуса и свечение (`Motion.pillSelect`).
struct MetricPill: View {
    let kind: MetricKind
    let valueText: String
    let state: HealthState
    let isSelected: Bool
    let accessibilityText: String
    let action: () -> Void

    private var statusColor: Color { state.tone.colors.text }

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                circle
                Text(kind.title)
                    .textStyle(.caption)
                    .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(TextScale.compact)
            }
            .frame(width: Size.pillWidth, height: Size.pillHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(Motion.pillSelect, value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind.title)
        .accessibilityValue(accessibilityText)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("pill-\(kind.rawValue)")
    }

    private var circle: some View {
        Text(valueText)
            .textStyle(.pillValue)
            .foregroundStyle(AppColor.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(TextScale.metric)
            .padding(.horizontal, Spacing.xs)
            .frame(width: Size.pill, height: Size.pill)
            .glassBackground(in: Circle())
            .overlay {
                Circle()
                    .strokeBorder(statusColor, lineWidth: Size.focusRing)
                    .opacity(isSelected ? 1 : 0)
            }
            .shadow(color: isSelected ? statusColor.opacity(0.45) : Color.clear, radius: Spacing.m)
    }
}

private func pillPreview(_ kind: MetricKind, _ value: String, _ state: HealthState, selected: Bool) -> some View {
    MetricPill(kind: kind, valueText: value, state: state, isSelected: selected, accessibilityText: value, action: {})
}

#Preview("MetricPill: ряд") {
    HStack(spacing: Spacing.s) {
        pillPreview(.pressure, "122/79", .normal, selected: true)
        pillPreview(.pulse, "68", .normal, selected: false)
        pillPreview(.weight, "72,4", .normal, selected: false)
        pillPreview(.glucose, AppFormat.dash, .noData, selected: false)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("MetricPill: состояния") {
    HStack(spacing: Spacing.s) {
        pillPreview(.pressure, "134/86", .elevated, selected: true)
        pillPreview(.pressure, "148/94", .high, selected: true)
        pillPreview(.glucose, AppFormat.dash, .noData, selected: true)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
