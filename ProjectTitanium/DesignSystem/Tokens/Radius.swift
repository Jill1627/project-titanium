import SwiftUI

struct Radius {
    static let sm: CGFloat = 10     // radius-sm: tags
    static let md: CGFloat = 14     // radius-md: inputs, small cards
    static let lg: CGFloat = 20     // radius-lg: standard cards
    static let xl: CGFloat = 28     // radius-xl: large cards, modals
    static let pill: CGFloat = 100  // radius-pill: buttons
}

extension View {
    func cornerRadius_sm() -> some View { self.clipShape(RoundedRectangle(cornerRadius: Radius.sm)) }
    func cornerRadius_md() -> some View { self.clipShape(RoundedRectangle(cornerRadius: Radius.md)) }
    func cornerRadius_lg() -> some View { self.clipShape(RoundedRectangle(cornerRadius: Radius.lg)) }
}
