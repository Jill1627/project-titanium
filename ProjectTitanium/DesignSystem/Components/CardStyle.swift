import SwiftUI

/// Standard Titanium Card Styling based on the official Design System Guide.
/// This modifier encapsulates the 4pt hard shadow, 1.5pt border, and optional corner bloom.
struct TitaniumCardModifier: ViewModifier {
    @Environment(\.theme) var theme
    var hasBloom: Bool = true
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 24
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Hard Shadow (4pt) as specified for interactive cards
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(theme.shadow.opacity(0.6))
                        .offset(x: 4, y: 4)

                    // Main Card Surface
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.surfaceCard)
                    
                    // Corner Bloom (Indie Warmth decoration)
                    if hasBloom {
                        RadialGradient(
                            colors: [theme.primary.opacity(0.12), .clear],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 180
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.borderDefault, lineWidth: 1.5)
            )
    }
}

extension View {
    /// Transforms any view into a standard 'Titanium' interactive card.
    /// - Parameter hasBloom: Set to true if there is significant white space in the bottom-right corner.
    func titaniumCardStyle(hasBloom: Bool = true) -> some View {
        self.modifier(TitaniumCardModifier(hasBloom: hasBloom))
    }
}

#Preview {
    VStack(spacing: 40) {
        Text("Standard Card")
            .titaniumCardStyle()
        
        Text("No Bloom Card")
            .titaniumCardStyle(hasBloom: false)
    }
    .padding()
}
