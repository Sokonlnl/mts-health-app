import SwiftUI

/// Карточка совета (Figma 63:25250): тёмная #1B1B1B 332×239, радиус 33,4, кромка белый 5%, зелёное размытое пятно справа
/// снизу. Заголовок, совет и автор с иконкой. Колоду из нескольких карточек собирает `AdviceDeckView`.
/// Знак ГигаЧата из Figma (`GigaChatMark`, белый, в карточке с прозрачностью 20%). Для VoiceOver одна связка текстов.
struct AdviceCard: View {
    let title: String
    let text: String
    let author: String
    let role: String
    /// Имя картинки в каталоге ресурсов (знак автора).
    let iconName: String
    /// Оговорка под советом (при повышенном и высоком давлении). `nil`: без неё.
    var disclaimer: String?

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(title)
                .textStyle(.adviceTitle)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(text)
                .textStyle(.adviceBody)
                .foregroundStyle(AppColor.adviceText)
                .fixedSize(horizontal: false, vertical: true)
            if let disclaimer {
                Text(disclaimer)
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: Spacing.s)
            authorRow
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, minHeight: Size.adviceHeight, alignment: .topLeading)
        .background {
            ZStack {
                GlassSurface(shape: shape, style: .solid)
                glow.clipShape(shape)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var authorRow: some View {
        HStack(spacing: Spacing.m) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: Size.adviceAvatar, height: Size.adviceAvatar)
                .opacity(Size.gigachatMarkOpacity)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(author)
                    .textStyle(.adviceBody)
                    .foregroundStyle(AppColor.textPrimary)
                Text(role)
                    .textStyle(.adviceBody)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }

    private var glow: some View {
        CornerGlow(
            color: AppColor.success.text, size: CGSize(width: Size.adviceGlowSize, height: Size.adviceGlowSize),
            blur: Size.adviceGlowBlur, opacity: Size.adviceGlowOpacity, shift: Size.cornerGlowShift, isDrifting: true
        )
    }
}

#Preview("AdviceCard") {
    AdviceCard(
        title: "Небольшая прогулка — забота о себе",
        text: "Начните с 10 минут на свежем воздухе в комфортном темпе.",
        author: "ГигаЧат",
        role: "Медицинский помощник",
        iconName: HomeText.gigachatMarkAsset
    )
    .padding(.horizontal, Spacing.screenMargin + Spacing.adviceInset)
    .padding(.bottom, Spacing.xxl)
    .background(AppColor.background)
}

#Preview("AdviceCard: длинный текст") {
    AdviceCard(
        title: "Пейте воду в течение дня и не откладывайте перерывы",
        text: "Небольшие стаканы воды помогают не забывать о питьевом режиме. Если есть ограничения, уточните их у врача.",
        author: "ГигаЧат",
        role: "Медицинский помощник",
        iconName: HomeText.gigachatMarkAsset
    )
    .padding(.horizontal, Spacing.screenMargin + Spacing.adviceInset)
    .padding(.bottom, Spacing.xxl)
    .background(AppColor.background)
}

#Preview("AdviceCard: с оговоркой (повышенное, высокое)") {
    AdviceCard(
        title: "Дайте себе немного покоя",
        text: "Посидите спокойно несколько минут и измерьте давление ещё раз.",
        author: "ГигаЧат",
        role: "Медицинский помощник",
        iconName: HomeText.gigachatMarkAsset,
        disclaimer: HomeText.adviceDisclaimerHigh
    )
    .padding(.horizontal, Spacing.screenMargin + Spacing.adviceInset)
    .padding(.bottom, Spacing.xxl)
    .background(AppColor.background)
}
