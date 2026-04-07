import SwiftUI

struct CCTModeView: View {
    var light: LightViewModel

    @State private var brr: Double = 50
    @State private var cctVal: Double = 53
    @State private var gmVal: Double = 0

    var body: some View {
        VStack(spacing: 14) {
            GradientSlider(
                value: $brr,
                range: 0...100,
                step: 1,
                gradient: .brightness,
                label: "BRR",
                valueLabel: "\(Int(brr))%"
            )

            GradientSlider(
                value: $cctVal,
                range: Double(light.cctRange.min)...Double(light.cctRange.max),
                step: 1,
                gradient: .cct,
                label: "CCT",
                valueLabel: "\(Int(cctVal))00K"
            )

            if light.supportGM {
                GradientSlider(
                    value: $gmVal,
                    range: -50...50,
                    step: 1,
                    gradient: .gm,
                    label: "GM",
                    valueLabel: gmVal >= 0 ? "+\(Int(gmVal))" : "\(Int(gmVal))"
                )
            }
        }
        .onAppear {
            brr = Double(light.brightness)
            cctVal = Double(light.cct)
            gmVal = Double(light.gm)
        }
        .onChange(of: brr) { sendCCT() }
        .onChange(of: cctVal) { sendCCT() }
        .onChange(of: gmVal) { sendCCT() }
    }

    private func sendCCT() {
        light.setCCT(brr: CGFloat(brr), cct: CGFloat(cctVal), gm: CGFloat(gmVal))
    }
}
