import Charts
import SwiftUI

/// График давления: две линии, цветные зоны по верхнему давлению, точка последнего значения.
struct PressureChartView: View {
    let measurements: [PressureMeasurement]
    let period: PressurePeriod
    let xDomain: ClosedRange<Date>
    let yDomain: ClosedRange<Int>
    let accessibilityValue: String

    var body: some View {
        Chart {
            ForEach(PressureZone.allCases, id: \.self) { zone in
                RectangleMark(
                    xStart: .value("Начало", xDomain.lowerBound),
                    xEnd: .value("Конец", xDomain.upperBound),
                    yStart: .value("От", zone.systolicBand(within: yDomain).lowerBound),
                    yEnd: .value("До", zone.systolicBand(within: yDomain).upperBound)
                )
                .foregroundStyle(zone.chartColor)
            }
            ForEach(measurements) { item in
                LineMark(
                    x: .value("Время", item.date),
                    y: .value("Верхнее", item.systolic),
                    series: .value("Показатель", "Верхнее")
                )
                .foregroundStyle(AppColor.pressure)
                .interpolationMethod(.monotone)
                LineMark(
                    x: .value("Время", item.date),
                    y: .value("Нижнее", item.diastolic),
                    series: .value("Показатель", "Нижнее")
                )
                .foregroundStyle(AppColor.textSecondary)
                .interpolationMethod(.monotone)
            }
            if let last = measurements.last {
                PointMark(x: .value("Время", last.date), y: .value("Верхнее", last.systolic))
                    .foregroundStyle(AppColor.pressure)
                    .symbolSize(Size.chartPoint)
                PointMark(x: .value("Время", last.date), y: .value("Нижнее", last.diastolic))
                    .foregroundStyle(AppColor.textSecondary)
                    .symbolSize(Size.chartPoint)
            }
        }
        .chartXScale(domain: xDomain)
        .chartYScale(domain: yDomain)
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisValueLabel(format: axisFormat)
            }
        }
        .chartPlotStyle { plot in
            plot.clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        }
        .environment(\.locale, Locale(identifier: "ru_RU"))
        .frame(height: Size.chartHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("График давления: верхнее и нижнее")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("pressure-chart")
    }

    private var axisFormat: Date.FormatStyle {
        switch period {
        case .day: return .dateTime.hour()
        case .week: return .dateTime.weekday(.abbreviated)
        case .month: return .dateTime.day().month(.abbreviated)
        case .sixMonths: return .dateTime.month(.abbreviated)
        }
    }
}

/// Легенда: линии и цветные зоны.
struct PressureChartLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(spacing: Spacing.l) {
                entry(color: AppColor.pressure, title: "Верхнее", isZone: false)
                entry(color: AppColor.textSecondary, title: "Нижнее", isZone: false)
            }
            HStack(spacing: Spacing.l) {
                ForEach(PressureZone.allCases, id: \.self) { zone in
                    entry(color: zone.chartColor, title: zone.title, isZone: true)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Легенда: верхнее и нижнее давление; зоны Норма, Повышенное, Высокое")
    }

    private func entry(color: Color, title: String, isZone: Bool) -> some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(color)
                .overlay { Circle().stroke(isZone ? AppColor.border : Color.clear, lineWidth: Size.hairline) }
                .frame(width: Size.legendDot, height: Size.legendDot)
            Text(title)
                .textStyle(.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

#Preview("PressureChart") {
    let now = Date()
    let items = (0..<7).map { index in
        PressureMeasurement(
            id: "p\(index)",
            date: now.addingTimeInterval(-Double(6 - index) * 86_400),
            systolic: 118 + index * 3,
            diastolic: 76 + index,
            pulse: 66,
            context: .morning
        )
    }
    return VStack(alignment: .leading, spacing: Spacing.m) {
        PressureChartView(
            measurements: items,
            period: .week,
            xDomain: now.addingTimeInterval(-7 * 86_400)...now,
            yDomain: 60...160,
            accessibilityValue: "Предпросмотр"
        )
        PressureChartLegend()
    }
    .padding(Spacing.l)
    .background(AppColor.surface)
}
