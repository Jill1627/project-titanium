import SwiftUI

struct Spacing {
    static let s1: CGFloat = 8   // space-1
    static let s2: CGFloat = 16  // space-2: margins, padding
    static let s3: CGFloat = 24  // space-3: card padding
    static let s4: CGFloat = 32  // space-4: between cards
    static let s5: CGFloat = 40  // space-5: section spacing
    static let s6: CGFloat = 48  // space-6: large breaks
    static let s8: CGFloat = 64  // space-8: hero room
}

extension View {
    func padding_s1() -> some View { self.padding(Spacing.s1) }
    func padding_s2() -> some View { self.padding(Spacing.s2) }
    func padding_s3() -> some View { self.padding(Spacing.s3) }
}
