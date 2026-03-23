import SwiftUI

extension Color {
    // MARK: — Semantic (system colors, free light/dark)
    static let surfacePage          = Color(.systemBackground)
    static let surfaceCard          = Color(.secondarySystemGroupedBackground)
    static let surfaceCardSubtle    = Color(.tertiarySystemGroupedBackground)
    static let surfaceInput         = Color(.secondarySystemBackground)
    static let surfaceNavBar        = Color(.systemBackground)
    static let surfaceTabBar        = Color(.systemBackground)
 
    static let textPrimary          = adaptive(light: Color(red: 0.059, green: 0.059, blue: 0.059), 
                                               dark: Color(red: 0.96, green: 0.96, blue: 0.96)) // #0F0F0F / #F5F5F5
    static let textSecondary        = adaptive(light: Color(red: 0.31, green: 0.31, blue: 0.31), 
                                               dark: Color(red: 0.7, green: 0.7, blue: 0.7))   // #4F4F4F / #B2B2B2
    static let textTertiary         = adaptive(light: Color(red: 0.46, green: 0.46, blue: 0.46), 
                                               dark: Color(red: 0.55, green: 0.55, blue: 0.55)) // #757575 / #8C8C8C
    static let textInverse          = adaptive(light: .white, dark: .black)
    static let textPlaceholder      = adaptive(light: Color(red: 0.6, green: 0.6, blue: 0.6), 
                                               dark: Color(red: 0.4, green: 0.4, blue: 0.4))
 
    static let borderDefault        = adaptive(light: Color(red: 0.2, green: 0.2, blue: 0.2), 
                                               dark: Color(red: 0.8, green: 0.8, blue: 0.8))
    static let borderSubtle         = adaptive(light: Color(red: 0.9, green: 0.9, blue: 0.9), 
                                               dark: Color(red: 0.2, green: 0.2, blue: 0.2))
    static let borderOpaque         = adaptive(light: Color(red: 0.85, green: 0.85, blue: 0.85), 
                                               dark: Color(red: 0.3, green: 0.3, blue: 0.3))
 
    static let fillButtonPrimary    = Color(.label)
    static let fillButtonSecondary  = Color(.secondarySystemGroupedBackground)
 
    static let iconDefault          = Color(.label)
    static let iconSubtle           = Color(.tertiaryLabel)
 
    // MARK: — Sport Themes (named in Asset Catalog)

    // MARK: — Special (custom Asset Catalog colors)
    static let achievementFill      = Color("achievement-fill")
    static let achievementSurface   = Color("achievement-surface")
    static let achievementBorder    = Color("achievement-border")
    static let achievementText      = Color("achievement-text")
    static let achievementSparkle   = Color("achievement-sparkle")
    static let moodSelected         = Color("mood-selected")
    static let sparkleFilled        = Color("sparkle-filled")

    // MARK: — Dynamic Helper
    private static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}