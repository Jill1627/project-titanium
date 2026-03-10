import SwiftUI

extension Color {
    static let accentMint = Color(red: 0, green: 1, blue: 0.8)   // #00FFCC
    static let accentCoral = Color(red: 1, green: 0.5, blue: 0.5) // #FF7F7F
}

extension ShapeStyle where Self == Color {
    static var mintAccent: Color { .accentMint }
    static var coralAccent: Color { .accentCoral }
}
