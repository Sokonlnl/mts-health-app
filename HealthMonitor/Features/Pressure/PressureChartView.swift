import Charts
import SwiftUI

/// График давления: цветные зоны по верхнему давлению, пунктир границ зон, две линии, точка последнего значения.
/// Границы зон берутся из `PressureZone.systolicBand`, не литералами.
struct PressureChartView: View {
    let measurements: [PressureMeasurement]
    let period: PressurePeriod
    let xDomain: ClosedRange<Date>
    let yDomain: ClosedRange<Int>
    let markerColor: Color
    let accessibilityValue: String

    private let dash: [CGFloat] = [Spacing.xs, Spacing.xs]

    /// Границы повышенной зоны по верхнему давлению: начало и верхняя граница.
    private var elevatedBand: ClosedRange<Int> {
        PressureZone.elevated.systolicBand(within: yDomain)
    }

    var body: some View {
        Chart {
            zoneBands
            zoneBorders
            lines
            lastPoint
        }
        .chartXScale(domain: xDomain)
        .chartYScale(domain: yDomain)
        .chartLegend(.hidden)
        .chartXAxis { xAxis }
        .chartYAxis { yAxis }
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

    // MARK: - Содержимое графика

    @ChartContentBuilder
    private var zoneBands: some ChartContent {
        ForEach(PressureZone.allCases, id: \.self) { zone in
            RectangleMark(
                xStart: .value("Начало", xDomain.lowerBound),
                xEnd: .value("Конец", xDomain.upperBound),
                yStart: .value("От", zone.systolicBand(within: yDomain).lowerBound),
                yEnd: .value("До", zone.systolicBand(within: yDomain).upperBound)
            )
            .foregroundStyle(zone.chartColor)
        }
    }

    @ChartContentBuilder
    private var zoneBorders: some ChartContent {
        RuleMark(y: .value("Граница", elevatedBand.lowerBound))
            .foregroundStyle(AppColor.zoneLineElevated)
            .lineStyle(StrokeStyle(lineWidth: Size.hairline, dash: dash))
        RuleMark(y: .value("Граница", elevatedBand.upperBound))
            .foregroundStyle(AppColor.zoneLineHigh)
            .lineStyle(StrokeStyle(lineWidth: Size.hairline, dash: dash))
    }

    @ChartContentBuilder
    private var lines: some ChartContent {
        ForEach(measurements) { item in
            LineMark(
                x: .value("Время", item.date),
                y: .value("Верхнее", item.systolic),
                series: .value("Показатель", "Верхнее")
            )
            .foregroundStyle(AppColor.chartUpper)
            .lineStyle(StrokeStyle(lineWidth: Size.chartLineUpper, lineCap: .round, lineJoin: .round))
            .interpolationMethod(.monotone)
            LineMark(
                x: .value("Время", item.date),
                y: .value("Нижнее", item.diastolic),
                series: .value("Показатель", "Нижнее")
            )
            .foregroundStyle(AppColor.chartLower)
            .lineStyle(StrokeStyle(lineWidth: Size.chartLineLower, lineCap: .round, lineJoin: .round))
            .interpolationMethod(.monotone)
        }
    }

    @ChartContentBuilder
    private var lastPoint: some ChartContent {
        if let last = measurements.last {
            PointMark(x: .value("Время", last.date), y: .value("Верхнее", last.systolic))
                .symbol {
                    AuraMarker(glow: markerColor, glowDiameter: Size.chartMarkerGlow, dotDiameter: Size.chartMarkerDot)
                }
        }
    }

    // MARK: - Оси

    @AxisContentBuilder
    private var xAxis: some AxisContent {
        AxisMarks(values: .automatic(desiredCount: 4)) { _ in
            AxisValueLabel(format: period.axisFormat)
                .foregroundStyle(AppColor.textTertiary)
        }
    }

    /// Метки границ зон: «130» и «140+».
    @AxisContentBuilder
    private var yAxis: some AxisContent {
        AxisMarks(values: [elevatedBand.lowerBound, elevatedBand.upperBound]) { value in
            AxisValueLabel {
                if let number = value.as(Int.self) {
                    Text(number == elevatedBand.upperBound ? "\(number)+" : "\(number)")
                        .textStyle(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
    }
}

/// Легенда: верхнее и нижнее.
struct PressureChartLegend: View {
    var body: some View {
        HStack(spacing: Spacing.l) {
            entry(color: AppColor.chartUpper, title: "Верхнее")
            entry(color: AppColor.chartLower, title: "Нижнее")
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Легенда: верхнее и нижнее давление")
    }

    private func entry(color: Color, title: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Capsule()
                .fill(color)
                .frame(width: Size.legendLine, height: Size.chartLineLower)
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
            xDomain: now.addingTimeInterval(-7 * 86_400)...now.addingTimeInterval(86_400),
            yDomain: 60...160,
            markerColor: HealthState.normal.palette.markerGlow,
            accessibilityValue: "Предпросмотр"
        )
        PressureChartLegend()
    }
    .glassCard()
    .padding(Spacing.l)
    .background(AppColor.background)
}
