import SwiftUI

extension Color {
    // MARK: — Semantic (system colors, free light/dark)
    static let surfacePage          = Color(.systemBackground)
    static let surfaceCard          = Color(.secondarySystemGroupedBackground)
    static let surfaceCardSubtle    = Color(.tertiarySystemGroupedBackground)
    static let surfaceInput         = Color(.secondarySystemBackground)
    static let surfaceNavBar        = Color(.systemBackground)
    static let surfaceTabBar        = Color(.systemBackground)
 
    static let textPrimary          = Color(.label)
    static let textSecondary        = Color(.secondaryLabel)
    static let textTertiary         = Color(.tertiaryLabel)
    static let textInverse          = Color(.systemBackground)
    static let textPlaceholder      = Color(.placeholderText)
 
    static let borderDefault        = Color(.label)
    static let borderSubtle         = Color(.separator)
    static let borderOpaque         = Color(.opaqueSeparator)
 
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
}