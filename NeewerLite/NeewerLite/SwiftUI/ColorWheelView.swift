import SwiftUI

struct ColorWheelView: View {
    @Binding var hue: Double         // 0-360
    @Binding var saturation: Double  // 0-100
    var onChanged: ((Double, Double) -> Void)? = nil

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2

            ZStack {
                // Color wheel image from asset catalog
                Image("colorWheel")
                    .resizable()
                    .frame(width: size, height: size)

                // Indicator circle at current hue/saturation
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 16, height: 16)
                    .position(indicatorPosition(center: center, radius: radius))
            }
            .frame(width: size, height: size)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let point = drag.location
                        let (h, s) = hueSaturationFromPoint(point, center: center, radius: radius)
                        hue = h
                        saturation = s
                        onChanged?(h, s)
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    /// Convert hue (0-360) and saturation (0-100) to a point on the wheel.
    /// Red is at the right (0/360 degrees), hues proceed counter-clockwise.
    private func indicatorPosition(center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = hue * .pi / 180.0
        let dist = (saturation / 100.0) * Double(radius)
        return CGPoint(
            x: center.x + CGFloat(dist * cos(angle)),
            y: center.y - CGFloat(dist * sin(angle))  // Screen Y is flipped
        )
    }

    /// Convert a point in the wheel's coordinate space to hue (0-360)
    /// and saturation (0-100), clamping to the wheel's radius.
    private func hueSaturationFromPoint(
        _ point: CGPoint,
        center: CGPoint,
        radius: CGFloat
    ) -> (Double, Double) {
        let dx = Double(point.x - center.x)
        let dy = Double(center.y - point.y)  // Flip Y for standard math coords
        let dist = sqrt(dx * dx + dy * dy)
        let clampedDist = min(dist, Double(radius))

        var angle = atan2(dy, dx)
        if angle < 0 { angle += 2 * .pi }

        let h = angle * 180.0 / .pi       // 0-360
        let s = (clampedDist / Double(radius)) * 100.0  // 0-100

        return (h, s)
    }
}
