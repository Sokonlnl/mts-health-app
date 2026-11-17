import SwiftUI

/// Маркер: свечение цвета статуса и белая точка. Используется на дуге зон и на графике давления.
struct AuraMarker: View {
    let glow: Color
    var glowDiameter: CGFloat = Size.markerGlow
    var dotDiameter: CGFloat = Size.markerDot

    var body: some View {
        ZStack {
            Circle()
                .fill(glow)
                .frame(width: glowDiameter, height: glowDiameter)
                .blur(radius: glowDiameter / 4)
            Circle()
                .fill(AppColor.textPrimary)
                .frame(width: dotDiameter, height: dotDiameter)
        }
        .accessibilityHidden(true)
    }
}

/// Дуга зон 240° вокруг формы (от 150°) с маркером текущего значения.
/// Маркер переезжает по дуге за `Motion.marker`: вращается контейнер, а не меняется смещение.
struct ZoneArcView: View {
    struct Segment: Identifiable {
        let id: Int
        let color: Color
        /// Начало и длина сегмента в долях дуги 0...1.
        let start: Double
        let fraction: Double
    }

    let segments: [Segment]
    /// Положение маркера 0...1; `nil`: маркера нет.
    let progress: Double?
    let markerGlow: Color

    private var diameter: CGFloat { Size.zoneArcRadius * 2 }
    private var sweepFraction: Double { Size.zoneArcSweep / 360 }

    var body: some View {
        ZStack {
            ForEach(segments) { segment in
                arc(segment)
            }
            if let progress {
                AuraMarker(glow: markerGlow)
                    .offset(x: Size.zoneArcRadius)
                    .rotationEffect(.degrees(Size.zoneArcStart + Size.zoneArcSweep * min(max(progress, 0), 1)))
                    .transition(.opacity)
            }
        }
        .frame(width: diameter, height: diameter)
        .animation(Motion.marker, value: progress)
        .accessibilityHidden(true)
    }

    private func arc(_ segment: Segment) -> some View {
        let gap = 0.008
        let from = sweepFraction * segment.start + gap
        let end = sweepFraction * (segment.start + segment.fraction) - gap
        return Circle()
            .trim(from: from, to: max(end, from))
            .stroke(segment.color, style: StrokeStyle(lineWidth: Size.zoneArcLine, lineCap: .round))
            .rotationEffect(.degrees(Size.zoneArcStart))
    }
}

extension ZoneArcView {
    /// Три сегмента давления по долям из `PressureScale`: зелёный 60%, янтарный 75%, красный 75%.
    static var pressureSegments: [Segment] {
        var start = 0.0
        var result: [Segment] = []
        for zone in PressureZone.allCases {
            let fraction = PressureScale.fraction(for: zone)
            result.append(Segment(id: zone.rawValue, color: zone.arcColor, start: start, fraction: fraction))
            start += fraction
        }
        return result
    }

    /// Нейтральная дуга для показателей без зон.
    static let neutralSegments = [
        Segment(id: 0, color: AppColor.neutral.text.opacity(0.4), start: 0, fraction: 1)
    ]
}

private struct ZoneArcPreview: View {
    let progress: Double?
    let palette: AuraPalette
    let isPressure: Bool

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            ZoneArcView(
                segments: isPressure ? ZoneArcView.pressureSegments : ZoneArcView.neutralSegments,
                progress: progress,
                markerGlow: palette.markerGlow
            )
        }
    }
}

#Preview("ZoneArc: давление, норма") {
    ZoneArcPreview(progress: 0.35, palette: .normal, isPressure: true)
}

#Preview("ZoneArc: давление, высокое") {
    ZoneArcPreview(progress: 0.85, palette: .high, isPressure: true)
}

#Preview("ZoneArc: нейтральная") {
    ZoneArcPreview(progress: 0.5, palette: .noData, isPressure: false)
}

#Preview("ZoneArc: без маркера") {
    ZoneArcPreview(progress: nil, palette: .noData, isPressure: false)
}
