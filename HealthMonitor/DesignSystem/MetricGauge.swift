import SwiftUI
import Foundation

/// Мини-шкала в малой карточке показателя. Чисто декоративная (значение читается текстом карточки), скрыта от VoiceOver.
/// `.bands`: три слегка скруглённые горизонтальные плашки (жёлтая приглушённая, зелёная с градиентом, жёлтая) и яркая
/// зелёная линия-маркер поперёк.
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

    // MARK: - Плашки

    private var bandsHeight: CGFloat {
        Size.gaugeBandWarning * 2 + Size.gaugeBandGood + Size.gaugeBandGap * 2
    }

    private var bandShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.gauge, style: .continuous)
    }

    private var bands: some View {
        VStack(spacing: Size.gaugeBandGap) {
            bandShape.fill(AppColor.gaugeWarning).frame(height: Size.gaugeBandWarning)
            bandShape
                .fill(LinearGradient(
                    colors: [AppColor.gaugeGoodTop, AppColor.gaugeGoodBottom], startPoint: .top, endPoint: .bottom
                ))
                .frame(height: Size.gaugeBandGood)
            bandShape.fill(AppColor.gaugeWarning).frame(height: Size.gaugeBandWarning)
        }
        .overlay(alignment: .top) {
            if let position {
                Capsule()
                    .fill(AppColor.gaugeMarker)
                    .frame(height: Size.gaugeMarker)
                    .offset(y: CGFloat(1 - clamped(position)) * (bandsHeight - Size.gaugeMarker))
            }
        }
        .frame(height: bandsHeight)
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
