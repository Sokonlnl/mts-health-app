import SwiftUI
import Foundation

/// Мини-шкала в малой карточке показателя. Чисто декоративная (значение читается текстом карточки), скрыта от VoiceOver.
/// `.bands`: пять горизонтальных полос (красная, жёлтая, зелёная с градиентом, жёлтая, красная) и тонкая линия-маркер.
/// `.arc`: полукруглая дуга с подсвеченным участком и маркером-точкой.
/// `position`: положение маркера 0...1 (у полос снизу вверх, у дуги слева направо), `nil`: маркера нет.
struct MetricGauge: View {
    enum Style {
        case bands
        case arc
    }

    let style: Style
    let position: Double?

    var body: some View {
        Group {
            switch style {
            case .bands: bands
            case .arc: arc
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: - Полосы

    private var bandsHeight: CGFloat {
        (Size.gaugeBandDanger + Size.gaugeBandWarning) * 2 + Size.gaugeBandGood
    }

    private var bands: some View {
        VStack(spacing: 0) {
            band(AppColor.gaugeDanger, height: Size.gaugeBandDanger)
            band(AppColor.gaugeWarning, height: Size.gaugeBandWarning)
            LinearGradient(
                colors: [AppColor.gaugeGoodTop, AppColor.gaugeGoodBottom], startPoint: .top, endPoint: .bottom
            )
            .frame(height: Size.gaugeBandGood)
            band(AppColor.gaugeWarning, height: Size.gaugeBandWarning)
            band(AppColor.gaugeDanger, height: Size.gaugeBandDanger)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.gauge, style: .continuous))
        .overlay(alignment: .top) {
            if let position {
                Capsule()
                    .fill(AppColor.textPrimary)
                    .frame(height: Size.gaugeMarker)
                    .offset(y: CGFloat(1 - clamped(position)) * (bandsHeight - Size.gaugeMarker))
            }
        }
        .frame(height: bandsHeight)
    }

    private func band(_ color: Color, height: CGFloat) -> some View {
        Rectangle().fill(color).frame(height: height)
    }

    // MARK: - Дуга

    private var arc: some View {
        let diameter = Size.gaugeArcDiameter
        let line = Size.gaugeArcLine
        let radius = (diameter - line) / 2
        let angle = Double.pi * (1 - clamped(position ?? 0))
        let style = StrokeStyle(lineWidth: line, lineCap: .round)
        return ZStack {
            Circle()
                .trim(from: 0.5, to: 1)
                .stroke(AppColor.gaugeTrack, style: style)
                .padding(line / 2)
            Circle()
                .trim(from: 0.5 + 0.5 * Size.gaugeArcLitStart, to: 0.5 + 0.5 * Size.gaugeArcLitEnd)
                .stroke(AppColor.gaugeLit, style: style)
                .padding(line / 2)
            if position != nil {
                Circle()
                    .fill(AppColor.textPrimary)
                    .frame(width: Size.gaugeDot, height: Size.gaugeDot)
                    .position(x: diameter / 2 + radius * CGFloat(cos(angle)), y: diameter / 2 - radius * CGFloat(sin(angle)))
            }
        }
        .frame(width: diameter, height: diameter)
        .frame(width: diameter, height: diameter / 2 + Size.gaugeDot / 2, alignment: .top)
        .clipped()
    }

    private func clamped(_ value: Double?) -> Double {
        min(1, max(0, value ?? 0))
    }
}

#Preview("MetricGauge: полосы") {
    HStack(spacing: Spacing.l) {
        MetricGauge(style: .bands, position: 0.2)
        MetricGauge(style: .bands, position: 0.5)
        MetricGauge(style: .bands, position: nil)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}

#Preview("MetricGauge: дуга") {
    VStack(spacing: Spacing.l) {
        MetricGauge(style: .arc, position: 0.1)
        MetricGauge(style: .arc, position: 0.5)
        MetricGauge(style: .arc, position: 0.9)
        MetricGauge(style: .arc, position: nil)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.background)
}
