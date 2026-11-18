import SwiftUI

/// Сердце из Figma (`docs/design/assets/heart.svg`, viewBox 330×296). Координаты нормализуются к `rect`:
/// сердце целиком занимает внешнюю часть viewBox (поля под размытие остаются прозрачными).
/// `Inset.outer` (основной слой 264×230) и `Inset.inner` (внутренние слои поменьше).
struct HeartShape: Shape {
    enum Layer {
        case outer
        case inner
    }

    static let viewBox = CGSize(width: 330, height: 296)

    var layer: Layer = .outer

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scaleX = rect.width / Self.viewBox.width
        let scaleY = rect.height / Self.viewBox.height
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * scaleX, y: rect.minY + y * scaleY)
        }
        switch layer {
        case .outer: outer(&path, point)
        case .inner: inner(&path, point)
        }
        return path
    }

    private func outer(_ path: inout Path, _ point: (CGFloat, CGFloat) -> CGPoint) {
        path.move(to: point(276.443, 53.1337))
        path.addCurve(
            to: point(253.904, 38.0847), control1: point(269.992, 46.6873), control2: point(262.333, 41.5736)
        )
        path.addCurve(
            to: point(227.314, 32.8), control1: point(245.474, 34.5957), control2: point(236.438, 32.8)
        )
        path.addCurve(
            to: point(200.724, 38.0847), control1: point(218.189, 32.8), control2: point(209.153, 34.5957)
        )
        path.addCurve(
            to: point(178.184, 53.1337), control1: point(192.294, 41.5736), control2: point(184.635, 46.6873)
        )
        path.addLine(to: point(164.797, 66.5059))
        path.addLine(to: point(151.409, 53.1337))
        path.addCurve(
            to: point(102.28, 32.8067), control1: point(138.379, 40.1185), control2: point(120.707, 32.8067)
        )
        path.addCurve(
            to: point(53.1502, 53.1337), control1: point(83.8525, 32.8067), control2: point(66.1801, 40.1185)
        )
        path.addCurve(
            to: point(32.8, 102.207), control1: point(40.1202, 66.1488), control2: point(32.8, 83.801)
        )
        path.addCurve(
            to: point(53.1502, 151.281), control1: point(32.8, 120.613), control2: point(40.1202, 138.266)
        )
        path.addLine(to: point(66.5376, 164.653))
        path.addLine(to: point(164.797, 262.8))
        path.addLine(to: point(263.056, 164.653))
        path.addLine(to: point(276.443, 151.281))
        path.addCurve(
            to: point(291.509, 128.767), control1: point(282.897, 144.837), control2: point(288.016, 137.187)
        )
        path.addCurve(
            to: point(296.8, 102.207), control1: point(295.002, 120.347), control2: point(296.8, 111.322)
        )
        path.addCurve(
            to: point(291.509, 75.6475), control1: point(296.8, 93.0928), control2: point(295.002, 84.0677)
        )
        path.addCurve(
            to: point(276.443, 53.1337), control1: point(288.016, 67.2273), control2: point(282.897, 59.577)
        )
        path.closeSubpath()
    }

    private func inner(_ path: inout Path, _ point: (CGFloat, CGFloat) -> CGPoint) {
        path.move(to: point(256.99, 87.509))
        path.addCurve(
            to: point(238.378, 75.1426), control1: point(251.663, 82.2117), control2: point(245.339, 78.0096)
        )
        path.addCurve(
            to: point(216.421, 70.8), control1: point(231.417, 72.2756), control2: point(223.956, 70.8)
        )
        path.addCurve(
            to: point(194.464, 75.1426), control1: point(208.886, 70.8), control2: point(201.425, 72.2756)
        )
        path.addCurve(
            to: point(175.852, 87.509), control1: point(187.503, 78.0096), control2: point(181.179, 82.2117)
        )
        path.addLine(to: point(164.797, 98.4974))
        path.addLine(to: point(153.742, 87.509))
        path.addCurve(
            to: point(113.173, 70.8055), control1: point(142.983, 76.8139), control2: point(128.39, 70.8055)
        )
        path.addCurve(
            to: point(72.6043, 87.509), control1: point(97.957, 70.8055), control2: point(83.3639, 76.8139)
        )
        path.addCurve(
            to: point(55.8, 127.835), control1: point(61.8447, 98.204), control2: point(55.8, 112.71)
        )
        path.addCurve(
            to: point(72.6043, 168.16), control1: point(55.8, 142.96), control2: point(61.8447, 157.465)
        )
        path.addLine(to: point(83.6591, 179.149))
        path.addLine(to: point(164.797, 259.8))
        path.addLine(to: point(245.935, 179.149))
        path.addLine(to: point(256.99, 168.16))
        path.addCurve(
            to: point(269.431, 149.66), control1: point(262.319, 162.865), control2: point(266.547, 156.579)
        )
        path.addCurve(
            to: point(273.8, 127.835), control1: point(272.315, 142.741), control2: point(273.8, 135.324)
        )
        path.addCurve(
            to: point(269.431, 106.009), control1: point(273.8, 120.345), control2: point(272.315, 112.929)
        )
        path.addCurve(
            to: point(256.99, 87.509), control1: point(266.547, 99.0903), control2: point(262.319, 92.8037)
        )
        path.closeSubpath()
    }
}
