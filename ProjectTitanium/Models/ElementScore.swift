import Foundation
import SwiftData

@Model
final class ElementScore {
    var id: UUID
    var elementCode: String
    var timestamp: Double
    var executionValue: Double
    var landing: String // LandingType rawValue
    var coachNote: String?
    var createdAt: Date

    @Relationship(inverse: \RunThrough.elements)
    var runThrough: RunThrough?

    init(
        elementCode: String,
        timestamp: Double,
        executionValue: Double = 0.0,
        landing: LandingType = .stuck,
        coachNote: String? = nil
    ) {
        self.id = UUID()
        self.elementCode = elementCode
        self.timestamp = timestamp
        self.executionValue = executionValue
        self.landing = landing.rawValue
        self.coachNote = coachNote
        self.createdAt = Date()
    }

    var landingType: LandingType {
        get { LandingType(rawValue: landing) ?? .stuck }
        set { landing = newValue.rawValue }
    }
}
