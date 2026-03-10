import Foundation
import SwiftData

@Model
final class PlannedProgramContent {
    var id: UUID
    var name: String
    var sport: String // SportType rawValue
    var elementCodes: [String]
    var createdAt: Date

    init(name: String, sport: SportType, elementCodes: [String] = []) {
        self.id = UUID()
        self.name = name
        self.sport = sport.rawValue
        self.elementCodes = elementCodes
        self.createdAt = Date()
    }

    var sportType: SportType {
        get { SportType(rawValue: sport) ?? .skating }
        set { sport = newValue.rawValue }
    }
}
