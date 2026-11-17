import SwiftUI

/// Бенто главного экрана: слева большая плитка, справа колонка из двух одинаковых плиток.
/// Высота `Size.bentoHeight`, зазор `Spacing.tileGap`; плитки (`glassTile()`) заполняют отданное место.
/// Контейнер раскладки, а не плитка: плитки остаются `MetricCard(layout: .tile)` и `SkeletonTile`.
struct BentoGrid<Main: View, Side: View>: View {
    @ViewBuilder let main: () -> Main
    /// Ровно две плитки.
    @ViewBuilder let side: () -> Side

    var body: some View {
        HStack(spacing: Spacing.tileGap) {
            main()
            VStack(spacing: Spacing.tileGap) {
                side()
            }
        }
        .frame(height: Size.bentoHeight)
    }
}

#Preview("BentoGrid: данные") {
    BentoGrid {
        MetricCard(kind: .pressure, valueText: "122/79", unit: AppUnit.pressure, statusText: "Норма", tone: .positive, layout: .tile)
    } side: {
        MetricCard(kind: .pulse, valueText: "68", unit: AppUnit.pulse, layout: .tile)
        MetricCard(kind: .weight, valueText: "74,2", unit: AppUnit.weight, layout: .tile)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.homeBackground)
}

#Preview("BentoGrid: нет данных") {
    BentoGrid {
        MetricCard(kind: .pressure, valueText: nil, unit: AppUnit.pressure, statusText: AppFormat.noData, layout: .tile)
    } side: {
        MetricCard(kind: .pulse, valueText: nil, unit: AppUnit.pulse, layout: .tile)
        MetricCard(kind: .weight, valueText: nil, unit: AppUnit.weight, layout: .tile)
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.homeBackground)
}

#Preview("BentoGrid: loading") {
    BentoGrid {
        SkeletonTile()
    } side: {
        SkeletonTile()
        SkeletonTile()
    }
    .padding(Spacing.screenMargin)
    .background(AppColor.homeBackground)
}
