import SwiftUI
import Foundation

/// Мини-шкала в малой карточке показателя. Чисто декоративная (значение читается текстом карточки), скрыта от VoiceOver.
/// `.bands`: три слегка скруглённые горизонтальные плашки (жёлтая приглушённая, зелёная с градиентом, жёлтая) и яркая
/// зелёная линия-маркер поперёк.
/// `.arc`: пологая дуга на всю ширину с подсвеченным участком и треугольным указателем.
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

    /// Пологая дуга на всю ширину: окружность большого радиуса, видна верхняя часть. Серая дорожка, яркий участок,
    /// пунктир над ней и треугольный указатель под дорожкой в положении значения.
    private var arc: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let sagitta = Size.gaugeArcSagitta
            let line = Size.gaugeArcLine
            let radius = (width * width / 4 + sagitta * sagitta) / (2 * sagitta)
            let center = CGPoint(x: width / 2, y: line / 2 + Size.gaugeArcDottedGap + radius)
            let trackStyle = StrokeStyle(lineWidth: line, lineCap: .round)
            ZStack {
                arcPath(center: center, radius: radius + Size.gaugeArcDottedGap, width: width, from: 0, to: 1)
                    .stroke(
                        AppColor.textPrimary.opacity(Size.gaugeArcDottedOpacity),
                        style: StrokeStyle(lineWidth: Size.gaugeArcDottedLine, lineCap: .butt, dash: [1, 3])
                    )
                arcPath(center: center, radius: radius, width: width, from: 0, to: 1)
                    .stroke(AppColor.gaugeTrack, style: trackStyle)
                arcPath(center: center, radius: radius, width: width, from: Size.gaugeArcLitStart, to: Size.gaugeArcLitEnd)
                    .stroke(AppColor.gaugeLit, style: trackStyle)
                if let position {
                    let x = width * CGFloat(clamped(position))
                    let dx = x - center.x
                    let y = center.y - (radius * radius - dx * dx).squareRoot()
                    marker
                        .position(x: x, y: y + line / 2 + Size.gaugeArcMarkerGap + Size.gaugeArcMarkerHeight / 2)
                }
            }
        }
        .frame(height: Size.gaugeArcHeight)
        .clipped()
    }

    /// Участок дуги между долями `from` и `to` по ширине.
    private func arcPath(center: CGPoint, radius: CGFloat, width: CGFloat, from: Double, to: Double) -> Path {
        func angle(_ fraction: Double) -> Angle {
            let dx = (CGFloat(fraction) - 0.5) * width
            return .radians(-Double.pi / 2 + asin(Double(dx / radius)))
        }
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: angle(from), endAngle: angle(to), clockwise: false)
        }
    }

    /// Указатель: небольшой скруглённый треугольник вершиной вверх.
    private var marker: some View {
        let width = Size.gaugeArcMarkerWidth
        let height = Size.gaugeArcMarkerHeight
        return Path { path in
            path.move(to: CGPoint(x: width / 2, y: 0))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
        }
        .fill(AppColor.textPrimary)
        .overlay {
            Path { path in
                path.move(to: CGPoint(x: width / 2, y: 0))
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .stroke(AppColor.textPrimary, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
        }
        .frame(width: width, height: height)
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
