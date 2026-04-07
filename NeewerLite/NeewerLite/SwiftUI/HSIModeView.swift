import SwiftUI

struct HSIModeView: View {
    var light: LightViewModel

    @State private var hueVal: Double = 0
    @State private var satVal: Double = 100
    @State private var brr: Double = 50

    var body: some View {
        VStack(spacing: 14) {
            ColorWheelView(
                hue: $hueVal,
                saturation: $satVal,
                onChanged: { h, s in
                    hueVal = h
                    satVal = s
                    sendHSI()
                }
            )
            .frame(height: 150)

            GradientSlider(
                value: $brr,
                range: 0...100,
                step: 1,
                gradient: .brightness,
                label: "BRR",
                valueLabel: "\(Int(brr))%"
            )

            HStack {
                Text("H: \(Int(hueVal))\u{00B0}")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                Spacer()
                Text("S: \(Int(satVal))%")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
        }
        .onAppear {
            hueVal = Double(light.hue)
            satVal = Double(light.saturation)
            brr = Double(light.brightness)
        }
        .onChange(of: brr) { sendHSI() }
    }

    private func sendHSI() {
        light.setHSI(brr: CGFloat(brr), hue: CGFloat(hueVal), sat: CGFloat(satVal))
    }
}
