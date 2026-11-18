import SwiftUI

/// Анимации из docs/DESIGN.md. Длительности и кривые только отсюда.
/// При `accessibilityReduceMotion` смена палитры свечения идёт без анимации.
enum Motion {
    /// Длительности в секундах.
    static let standardDuration: Double = 0.25
    static let fastDuration: Double = 0.2
    static let paletteDuration: Double = 1.1
    static let contentSwapDuration: Double = 0.7
    /// Сколько подсказка «Скоро» остаётся на экране (нс).
    static let toastNanoseconds: UInt64 = 2_000_000_000

    /// Разворот и сворачивание блоков.
    static let standard = Animation.easeInOut(duration: standardDuration)
    /// Остальные быстрые переходы.
    static let fast = Animation.easeInOut(duration: fastDuration)
    /// Смена палитры при смене состояния или показателя (кроссфейд форм).
    static let palette = Animation.easeInOut(duration: paletteDuration)
    /// Появление текста значения и заголовка.
    static let contentSwap = Animation.timingCurve(0.2, 0.7, 0.2, 1, duration: contentSwapDuration)
    /// Переключатель периодов.
    static let segment = Animation.easeInOut(duration: 0.3)
    /// Выезд шторки.
    static let sheet = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.45)
    /// Подложка под шторкой.
    static let sheetScrim = Animation.easeInOut(duration: 0.25)

    // Дыхание свечения (`DomeGlow`): медленно, в пределах нескольких процентов, у пятен разные фазы (рад).
    static let breathePeriod: TimeInterval = 5
    static let breatheScaleAmplitude: Double = 0.04
    static let breatheOpacityAmplitude: Double = 0.06
    static let breathePhases: [Double] = [0, 2.1, 4.2]

    /// Сердцебиение в карточке давления: мягкое «дыхание-удар», на сколько растёт сердце в пике. Период задаёт
    /// `HeartbeatRhythm` (60 / пульс × 3 с, 2,5–3,5 с).
    static let heartbeatAmplitude: Double = 0.06

    // Герой главного (картинка `HeroGlow`): «дыхание» в пределах 2–3%, медленно.
    static let heroBreatheScaleAmplitude: Double = 0.025
    static let heroBreatheOpacityAmplitude: Double = 0.03
    static let heroBreathePeriod: TimeInterval = 6

    // Дрейф свечений главного: медленный плавный сдвиг по эллипсу. Периоды по осям разные, поэтому движение не повторяется в такт.
    /// Свечение героя: на сколько pt уходит по горизонтали и вертикали и за сколько секунд проходит полный круг по каждой оси.
    static let heroDriftX: CGFloat = 16
    static let heroDriftY: CGFloat = 8
    static let heroDriftPeriodX: TimeInterval = 11
    static let heroDriftPeriodY: TimeInterval = 17
    /// Зелёное пятно в карточке совета.
    static let cornerGlowDrift: CGFloat = 8
    static let cornerGlowDriftPeriod: TimeInterval = 9
    /// Свет кнопки ГигаЧата: на какую долю ширины уходит центр света и за сколько секунд проходит туда и обратно.
    static let buttonLightDrift: Double = 0.2
    static let buttonLightPeriod: TimeInterval = 8

    // Колода советов: смахивание (пружина), порог и вылет карточки за экран.
    static let adviceSwipe = Animation.spring(response: 0.42, dampingFraction: 0.82)
    static let adviceSwipeThreshold: CGFloat = 80
    static let adviceFlyOut: CGFloat = 420
    static let adviceTiltDivisor: CGFloat = 40

    // Заставка при первом показе главного: свечение разгорается из темноты, затем элементы по очереди поднимаются снизу.
    static let introGlow = Animation.easeOut(duration: 0.7)
    static let introItemDuration: Double = 0.35
    static let introItemStart: Double = 0.25
    static let introItemStagger: Double = 0.08
    /// Общая длительность заставки после загрузки данных (нс): после неё она считается сыгранной.
    static let introNanoseconds: UInt64 = 1_100_000_000
    /// Сдвиг вверх при появлении элемента.
    static let introOffset: CGFloat = 12

    /// Появление элемента заставки с номером `index` (0 первый): кривая как у `contentSwap`, задержка по очереди.
    static func introItem(index: Int) -> Animation {
        Animation.timingCurve(0.2, 0.7, 0.2, 1, duration: introItemDuration)
            .delay(introItemStart + introItemStagger * Double(index))
    }

    /// Появление: прозрачность 0 в 1, сдвиг вниз на 8 pt, масштаб 0,98 в 1.
    static let contentSwapTransition = AnyTransition.opacity
        .combined(with: .offset(y: 8))
        .combined(with: .scale(scale: 0.98))
}

/// Фоновое движение (анимация смены палитры свечения). Выключается в snapshot-тестах,
/// чтобы кадр был детерминированным. Системный `accessibilityReduceMotion` проверяется отдельно.
private struct AmbientMotionKey: EnvironmentKey {
    static let defaultValue = true
}

/// Можно ли включать фоновое движение (дыхание свечения, сердцебиение, заставка): нет «Уменьшить движение»
/// и оно не выключено окружением `isAmbientMotionEnabled` (snapshot-тесты).
struct AmbientMotionGate: DynamicProperty {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isAmbientMotionEnabled) private var isAmbientMotionEnabled

    var isEnabled: Bool { !reduceMotion && isAmbientMotionEnabled }
}

extension EnvironmentValues {
    var isAmbientMotionEnabled: Bool {
        get { self[AmbientMotionKey.self] }
        set { self[AmbientMotionKey.self] = newValue }
    }
}

#Preview("Motion") {
    MotionDemo()
}

private struct MotionDemo: View {
    @State private var isOn = false

    var body: some View {
        VStack(spacing: Spacing.l) {
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .fill(AppColor.textPrimary)
                .frame(width: isOn ? 176 : 88, height: Size.iconButton)
            Button("standard \(Motion.standardDuration)") { withAnimation(Motion.standard) { isOn.toggle() } }
            Button("palette \(Motion.paletteDuration)") { withAnimation(Motion.palette) { isOn.toggle() } }
            Button("segment") { withAnimation(Motion.segment) { isOn.toggle() } }
        }
        .padding(Spacing.screenMargin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}
