import SwiftUI

/// Typography tokens derived from titanium-typography.json
extension Font {
    // MARK: — Display & Score (Sharpie)
    static let scoreHero        = Font.custom("Sharpie-Extrabold", size: 72)
    static let scoreLarge       = Font.custom("Sharpie-Extrabold", size: 56)
    static let scoreMedium      = Font.custom("Sharpie-Bold", size: 36)
    static let headerXL         = Font.custom("Sharpie-Bold", size: 32)
    static let headerLG         = Font.custom("DM Sans", size: 26).weight(.bold)
    static let headerMD         = Font.custom("DM Sans", size: 22).weight(.bold)
    static let headerSM         = Font.custom("DM Sans", size: 18).weight(.bold)
    
    // MARK: — Labels & Body (DM Sans - Variable Font)
    static let labelCaps        = Font.custom("DM Sans", size: 11)
    static let labelCapsSM      = Font.custom("DM Sans", size: 10).weight(.bold)
    static let bodyLG           = Font.custom("DM Sans", size: 17).weight(.regular)
    static let bodyMD           = Font.custom("DM Sans", size: 15).weight(.regular)
    static let bodyLight        = Font.custom("DM Sans", size: 15).weight(.light)
    static let caption          = Font.custom("DM Sans", size: 13).weight(.light)
    static let captionXS         = Font.custom("DM Sans", size: 12).weight(.light)
}

extension View {
    // Score Styles
    func scoreHeroStyle() -> some View {
        self.font(.scoreHero)
            .kerning(72 * -0.03)
            .lineSpacing(72 * (0.95 - 1.0))
    }
    
    func scoreMediumStyle() -> some View {
        self.font(.scoreMedium)
            .kerning(36 * -0.02)
            .lineSpacing(36 * (1.1 - 1.0))
    }
    
    // Header Styles
    func headerXLStyle() -> some View {
        self.font(.headerXL)
            .kerning(32 * -0.02)
            .lineSpacing(32 * (1.1 - 1.0))
    }
    
    func headerLGStyle() -> some View {
        self.font(.headerLG)
            .lineSpacing(26 * (1.1 - 1.0))
    }
    
    func headerMDStyle() -> some View {
        self.font(.headerMD)
            .lineSpacing(22 * (1.1 - 1.0))
    }
    
    func headerSMStyle() -> some View {
        self.font(.headerSM)
            .lineSpacing(18 * (1.1 - 1.0))
    }
    
    // Body Styles
    func bodyLGStyle() -> some View {
        self.font(.bodyLG)
            .lineSpacing(17 * (1.65 - 1.0))
    }
    
    func bodyMDStyle() -> some View {
        self.font(.bodyMD)
            .lineSpacing(15 * (1.65 - 1.0))
    }
    
    func captionStyle() -> some View {
        self.font(.caption)
            .lineSpacing(13 * (1.6 - 1.0))
    }
    
    // Label Styles
    func labelCapsStyle(isWider: Bool = false) -> some View {
        self.font(.labelCaps)
            .textCase(.uppercase)
            .kerning(11 * (isWider ? 0.18 : 0.15))
    }
}
