import SwiftUI

// MARK: - Gradient Type

enum SliderGradient {
    case brightness
    case cct
    case gm
    case hue
    case saturation
    case speed
    case spark
}

// MARK: - GradientSlider

struct GradientSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double = 0
    var gradient: SliderGradient = .brightness
    var label: String = ""
    var valueLabel: String = ""
    var onChanged: ((Double) -> Void)? = nil

    private let trackHeight: CGFloat = 20
    private let trackRadius: CGFloat = 4
    private let knobWidth: CGFloat = 10
    private let knobHeight: CGFloat = 24
    private let knobRadius: CGFloat = 3

    var body: some View {
        HStack(spacing: 6) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .leading)
            }

            GeometryReader { geo in
                let trackWidth = geo.size.width
                ZStack(alignment: .leading) {
                    trackView(width: trackWidth)
                    knobView(trackWidth: trackWidth)
                }
                .contentShape(Rectangle())
                .gesture(dragGesture(trackWidth: trackWidth))
            }
            .frame(height: knobHeight)

            if !valueLabel.isEmpty {
                Text(valueLabel)
                    .font(.system(size: 11).monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .trailing)
            }
        }
    }

    // MARK: - Track

    @ViewBuilder
    private func trackView(width: CGFloat) -> some View {
        switch gradient {
        case .speed, .spark:
            Canvas { context, size in
                drawDiscreteBlocks(context: context, size: size)
            }
            .frame(height: trackHeight)
            .clipShape(RoundedRectangle(cornerRadius: trackRadius))
        default:
            RoundedRectangle(cornerRadius: trackRadius)
                .fill(linearGradientFill)
                .frame(height: trackHeight)
        }
    }

    private var linearGradientFill: LinearGradient {
        switch gradient {
        case .brightness:
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.2, blue: 0.2),
                    Color(red: 0.7, green: 0.7, blue: 0.7),
                    .white
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .cct:
            return LinearGradient(
                colors: [
                    Color(red: 0.8, green: 0.6, blue: 0.2),
                    .white,
                    Color(red: 0.2, green: 0.6, blue: 0.8)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .gm:
            return LinearGradient(
                colors: [
                    Color(red: 0.88, green: 0.6, blue: 0.6),
                    .white,
                    Color(red: 0.4, green: 0.6, blue: 0.4)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .hue:
            return LinearGradient(
                stops: [
                    .init(color: .red, location: 0),
                    .init(color: .orange, location: 1.0 / 6.0),
                    .init(color: .yellow, location: 2.0 / 6.0),
                    .init(color: .green, location: 3.0 / 6.0),
                    .init(color: .blue, location: 4.0 / 6.0),
                    .init(color: .purple, location: 5.0 / 6.0),
                    .init(color: .red, location: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .saturation:
            return LinearGradient(
                colors: [
                    .white,
                    Color(hue: 240.0 / 360.0, saturation: 1, brightness: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .speed, .spark:
            // Unreachable — discrete types use Canvas
            return LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing)
        }
    }

    // MARK: - Discrete Blocks (Speed / Spark)

    private func drawDiscreteBlocks(context: GraphicsContext, size: CGSize) {
        let blockCount = max(Int(range.upperBound), 1)
        let gap: CGFloat = 3
        let totalGaps = CGFloat(blockCount - 1) * gap
        let blockWidth = (size.width - totalGaps) / CGFloat(blockCount)

        let isSpeed = (gradient == .speed)
        let baseHue: Double = isSpeed ? 0.645 : 0.045
        let baseBrightness: Double = isSpeed ? 0.2 : 0.3
        let brightnessStep: Double = isSpeed ? 0.1 : 0.09

        for i in 0..<blockCount {
            let x = CGFloat(i) * (blockWidth + gap)
            let rect = CGRect(x: x, y: 0, width: blockWidth, height: size.height)
            let brightness = min(baseBrightness + Double(i) * brightnessStep, 1.0)
            let color = Color(hue: baseHue, saturation: 0.8, brightness: brightness)
            let path = RoundedRectangle(cornerRadius: 2).path(in: rect)
            context.fill(path, with: .color(color))
        }
    }

    // MARK: - Knob

    private func knobView(trackWidth: CGFloat) -> some View {
        let fraction = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let clampedFraction = min(max(fraction, 0), 1)
        let knobX = clampedFraction * (trackWidth - knobWidth)

        return RoundedRectangle(cornerRadius: knobRadius)
            .fill(.white)
            .frame(width: knobWidth, height: knobHeight)
            .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1)
            .offset(x: knobX)
    }

    // MARK: - Gesture

    private func dragGesture(trackWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                updateValue(locationX: drag.location.x, trackWidth: trackWidth)
            }
    }

    private func updateValue(locationX: CGFloat, trackWidth: CGFloat) {
        let usableWidth = trackWidth - knobWidth
        guard usableWidth > 0 else { return }

        let fraction = Double((locationX - knobWidth / 2) / usableWidth)
        let clampedFraction = min(max(fraction, 0), 1)
        var newValue = range.lowerBound + clampedFraction * (range.upperBound - range.lowerBound)

        if step > 0 {
            newValue = (newValue / step).rounded() * step
        }
        newValue = min(max(newValue, range.lowerBound), range.upperBound)

        if newValue != value {
            value = newValue
            onChanged?(newValue)
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(macOS 14.0, *)
#Preview("GradientSlider") {
    struct PreviewHost: View {
        @State private var brightness: Double = 50
        @State private var cct: Double = 5600
        @State private var gm: Double = 0
        @State private var hue: Double = 180
        @State private var sat: Double = 50
        @State private var speed: Double = 3
        @State private var spark: Double = 4

        var body: some View {
            VStack(spacing: 12) {
                GradientSlider(
                    value: $brightness, range: 0...100,
                    gradient: .brightness, label: "BRI",
                    valueLabel: "\(Int(brightness))%"
                )
                GradientSlider(
                    value: $cct, range: 2700...6500, step: 100,
                    gradient: .cct, label: "CCT",
                    valueLabel: "\(Int(cct))K"
                )
                GradientSlider(
                    value: $gm, range: -50...50,
                    gradient: .gm, label: "GM",
                    valueLabel: "\(Int(gm))"
                )
                GradientSlider(
                    value: $hue, range: 0...360,
                    gradient: .hue, label: "HUE",
                    valueLabel: "\(Int(hue))°"
                )
                GradientSlider(
                    value: $sat, range: 0...100,
                    gradient: .saturation, label: "SAT",
                    valueLabel: "\(Int(sat))%"
                )
                GradientSlider(
                    value: $speed, range: 1...8, step: 1,
                    gradient: .speed, label: "SPD",
                    valueLabel: "\(Int(speed))"
                )
                GradientSlider(
                    value: $spark, range: 1...10, step: 1,
                    gradient: .spark, label: "SPK",
                    valueLabel: "\(Int(spark))"
                )
            }
            .padding()
            .frame(width: 400)
        }
    }
    return PreviewHost()
}
#endif
