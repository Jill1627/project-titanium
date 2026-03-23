import SwiftUI

struct InteractiveShadow: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let isPressed: Bool

    func body(content: Content) -> some View {
        content
            .shadow(
                color: colorScheme == .dark ? .black : Color(.label),
                radius: 0,
                x: isPressed ? 1 : 3,
                y: isPressed ? 1 : 3
            )
            .offset(x: isPressed ? 2 : 0, y: isPressed ? 2 : 0) // Smooth translate effect
    }
}

extension View {
    func interactiveShadow(isPressed: Bool = false) -> some View {
        self.modifier(InteractiveShadow(isPressed: isPressed))
    }
}
