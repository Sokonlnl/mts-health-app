import SwiftUI

/// Семь столбиков давления за последние дни: последний подсвечен свечением, повышенный день янтарный.
struct WeekBarsChart: View {
    let bars: [WeekBar]

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.s) {
            ForEach(bars) { bar in
                column(bar)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Давление за 7 дней")
        .accessibilityValue(bars.map(\.accessibilityText).joined(separator: ", "))
        .accessibilityIdentifier("week-bars")
    }

    private func column(_ bar: WeekBar) -> some View {
        VStack(spacing: Spacing.xs) {
            RoundedRectangle(cornerRadius: Radius.pill, style: .continuous)
                .fill(color(bar))
                .frame(width: Size.weekBarWidth, height: height(bar))
                .shadow(color: bar.isToday ? AppColor.textPrimary.opacity(0.45) : Color.clear, radius: Spacing.s)
                .frame(height: Size.weekBarHeight, alignment: .bottom)
            Text(bar.label)
                .textStyle(.caption)
                .foregroundStyle(bar.isToday ? AppColor.textPrimary : AppColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(TextScale.compact)
        }
    }

    private func height(_ bar: WeekBar) -> CGFloat {
        guard bar.ratio > 0 else { return Size.weekBarMinimum }
        return Size.weekBarHeight * CGFloat(bar.ratio)
    }

    private func color(_ bar: WeekBar) -> Color {
        if bar.ratio == 0 { return AppColor.fill }
        if bar.isElevated { return AppColor.warning.text }
        return bar.isToday ? AppColor.textPrimary : AppColor.bar
    }
}

#Preview("WeekBarsChart") {
    let bars = [
        WeekBar(id: 0, label: "Ср", systolic: 118, isElevated: false, isToday: false, ratio: 0.4),
        WeekBar(id: 1, label: "Чт", systolic: 124, isElevated: false, isToday: false, ratio: 0.55),
        WeekBar(id: 2, label: "Пт", systolic: 134, isElevated: true, isToday: false, ratio: 0.8),
        WeekBar(id: 3, label: "Сб", systolic: nil, isElevated: false, isToday: false, ratio: 0),
        WeekBar(id: 4, label: "Вс", systolic: 121, isElevated: false, isToday: false, ratio: 0.45),
        WeekBar(id: 5, label: "Пн", systolic: 126, isElevated: false, isToday: false, ratio: 0.6),
        WeekBar(id: 6, label: "Вт", systolic: 122, isElevated: false, isToday: true, ratio: 0.5)
    ]
    return WeekBarsChart(bars: bars)
        .glassCard()
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
