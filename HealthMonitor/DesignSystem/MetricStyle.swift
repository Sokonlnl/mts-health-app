import SwiftUI

/// Визуальные атрибуты доменных типов: цвета и иконки.
extension MetricKind {
    var color: Color {
        switch self {
        case .pressure: return AppColor.pressure
        case .pulse: return AppColor.pulse
        case .weight: return AppColor.weight
        case .glucose: return AppColor.glucose
        }
    }

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

    /// Цвет сегмента дуги зон: зелёный 60%, янтарный 75%, красный 75%.
    var arcColor: Color {
        switch self {
        case .normal: return AppColor.success.text.opacity(0.60)
        case .elevated: return AppColor.warning.text.opacity(0.75)
        case .high: return AppColor.danger.text.opacity(0.75)
        }
    }
}
