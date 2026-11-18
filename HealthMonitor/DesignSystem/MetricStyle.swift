import SwiftUI

/// Визуальные атрибуты доменных типов: цвета и иконки.
extension MetricKind {
    var iconName: String {
        switch self {
        case .pressure: return "heart.fill"
        case .pulse: return "waveform.path.ecg"
        case .weight: return "scalemass.fill"
        case .glucose: return "drop.fill"
        }
    }
}

extension StatusTone {
    var colors: StatusColor {
        switch self {
        case .positive: return AppColor.success
        case .caution: return AppColor.warning
        case .critical: return AppColor.danger
        case .neutral: return AppColor.neutral
        }
    }
}

extension PressureZone {
    /// Цвет полосы зоны на графике.
    var chartColor: Color {
        switch self {
        case .normal: return AppColor.zoneNormal
        case .elevated: return AppColor.zoneElevated
        case .high: return AppColor.zoneHigh
        }
    }
}
