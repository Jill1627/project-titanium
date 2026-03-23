import SwiftUI
import Observation

// Theme constants relocated to SportType in Core models.

@Observable
class ThemeManager {
    var activeTheme: SportType = .skating

    // MARK: — Sport Tokens (resolved via active theme)
    var primary: Color {
        switch activeTheme {
        case .skating: return Color("skating-primary")
        // case .gymnastics: return Color("gymnastics-primary")
        default: return Color("skating-primary")
        }
    }
 
    var shadow: Color {
        switch activeTheme {
        case .skating: return Color("skating-shadow")
        // case .gymnastics: return Color("gymnastics-shadow")
        default: return Color("skating-shadow")
        }
    }
 
    var border: Color {
        switch activeTheme {
        case .skating: return Color("skating-border")
        // case .gymnastics: return Color("gymnastics-border")
        default: return Color("skating-border")
        }
    }
}

struct ThemeKey: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var theme: ThemeManager {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
