import SwiftUI

enum BrandFont {
    case black, bold, extrabold, light, regular, medium

    var name: String {
        switch self {
        case .black: return "Sharpie-Black"
        case .bold: return "Sharpie-Bold"
        case .extrabold: return "Sharpie-Extrabold"
        case .light: return "Sharpie-Light"
        case .regular: return "Sharpie-Regular"
        case .medium: return "Sharpie-Bold" // Fallback to Bold if Medium is missing
        }
    }

    /// Dynamic Type compliant custom font
    func size(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        Font.custom(self.name, size: size, relativeTo: style)
    }
}

extension View {
    func brandFont(_ font: BrandFont, size: CGFloat, relativeTo style: Font.TextStyle = .body) -> some View {
        self.font(font.size(size, relativeTo: style))
    }
}
