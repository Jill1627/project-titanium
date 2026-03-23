import SwiftUI

/// A native vector illustration of a Sparkle, derived from the Pencil design system.
/// Supports a fill and an outline natively without hacks.
struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Scale factor relative to 40x40 original design
        let sx = w / 40.0
        let sy = h / 40.0
        
        path.move(to: CGPoint(x: 20 * sx, y: 0))
        path.addLine(to: CGPoint(x: 22.2 * sx, y: 16.8 * sy))
        path.addLine(to: CGPoint(x: 40 * sx, y: 20 * sy))
        path.addLine(to: CGPoint(x: 22.2 * sx, y: 23.2 * sy))
        path.addLine(to: CGPoint(x: 20 * sx, y: 40 * sy))
        path.addLine(to: CGPoint(x: 17.8 * sx, y: 23.2 * sy))
        path.addLine(to: CGPoint(x: 0, y: 20 * sy))
        path.addLine(to: CGPoint(x: 17.8 * sx, y: 16.8 * sy))
        path.closeSubpath()
        return path
    }
}

struct SparkleIllustration: View {
    var size: CGFloat = 28
    var fillColor: Color = Color.orange
    var outlineColor: Color = Color.borderDefault
    
    var body: some View {
        ZStack {
            SparkleShape()
                .fill(fillColor)
            
            SparkleShape()
                .stroke(outlineColor, lineWidth: 0.3)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack {
        SparkleIllustration()
        SparkleIllustration(size: 48, fillColor: .yellow)
    }
}
