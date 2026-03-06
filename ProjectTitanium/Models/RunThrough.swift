import Foundation
import SwiftData

@Model
final class RunThrough {
    var id: UUID
    var athleteName: String
    var sport: String // SportType rawValue
    var videoLocalIdentifier: String
    var date: Date
    var totalScore: Double

    @Relationship(deleteRule: .cascade)
    var elements: [ElementScore]

    init(
        athleteName: String,
        sport: SportType,
        videoLocalIdentifier: String,
        date: Date = Date(),
        totalScore: Double = 0.0
    ) {
        self.id = UUID()
        self.athleteName = athleteName
        self.sport = sport.rawValue
        self.videoLocalIdentifier = videoLocalIdentifier
        self.date = date
        self.totalScore = totalScore
        self.elements = []
    }

    var sportType: SportType {
        get { SportType(rawValue: sport) ?? .skating }
        set { sport = newValue.rawValue }
    }
}
