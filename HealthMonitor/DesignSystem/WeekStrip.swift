import SwiftUI

/// Неделя в строке: Пн–Вс, точка в дни с измерением, янтарная точка при повышенном значении.
struct WeekStrip: View {
    let days: [WeekDay]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                column(day)
            }
        }
        .cardStyle(insets: CardInsets.compact)
    }

    private func column(_ day: WeekDay) -> some View {
        VStack(spacing: Spacing.s) {
            Text(day.label)
                .textStyle(.caption)
                .foregroundStyle(AppColor.textSecondary)
            Text("\(day.dayNumber)")
                .textStyle(.bodyStrong)
                .foregroundStyle(day.isToday ? AppColor.surface : AppColor.textPrimary)
                .frame(width: Size.dayCircle, height: Size.dayCircle)
                .background(day.isToday ? AppColor.accent : Color.clear, in: Circle())
            Circle()
                .fill(dotColor(day))
                .frame(width: Size.dot, height: Size.dot)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.accessibilityText)
    }

    private func dotColor(_ day: WeekDay) -> Color {
        if !day.hasMeasurement { return Color.clear }
        return day.isElevated ? AppColor.warning.text : AppColor.accent
    }
}

#Preview("WeekStrip") {
    let days = [
        WeekDay(id: 0, label: "Пн", dayNumber: 10, hasMeasurement: true, isElevated: false, isToday: false),
        WeekDay(id: 1, label: "Вт", dayNumber: 11, hasMeasurement: true, isElevated: true, isToday: false),
        WeekDay(id: 2, label: "Ср", dayNumber: 12, hasMeasurement: true, isElevated: false, isToday: false),
        WeekDay(id: 3, label: "Чт", dayNumber: 13, hasMeasurement: false, isElevated: false, isToday: false),
        WeekDay(id: 4, label: "Пт", dayNumber: 14, hasMeasurement: true, isElevated: false, isToday: true),
        WeekDay(id: 5, label: "Сб", dayNumber: 15, hasMeasurement: false, isElevated: false, isToday: false),
        WeekDay(id: 6, label: "Вс", dayNumber: 16, hasMeasurement: false, isElevated: false, isToday: false)
    ]
    return WeekStrip(days: days)
        .padding(Spacing.screenMargin)
        .background(AppColor.background)
}
