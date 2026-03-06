import Foundation
import SwiftData

@Model
final class Athlete {
    var id: UUID
    var name: String
    var sport: String // SportType rawValue
    var createdAt: Date

    init(name: String, sport: SportType) {
        self.id = UUID()
        self.name = name
        self.sport = sport.rawValue
        self.createdAt = Date()
    }

    var sportType: SportType {
        get { SportType(rawValue: sport) ?? .skating }
        set { sport = newValue.rawValue }
    }
}
