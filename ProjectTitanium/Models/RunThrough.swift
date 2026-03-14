import Foundation
import SwiftData

@Model
final class RunThrough: Hashable {
    var id: UUID
    var athleteID: UUID
    var programName: String
    var sport: String // SportType rawValue
    var videoLocalIdentifier: String
    var date: Date
    var totalScore: Double
    var coachNote: String?

    @Relationship(deleteRule: .cascade)
    var elements: [ElementScore]

    init(
        athleteID: UUID,
        programName: String = "Untitled Program",
        sport: SportType,
        videoLocalIdentifier: String,
        date: Date = Date(),
        totalScore: Double = 0.0,
        coachNote: String? = nil
    ) {
        self.id = UUID()
        self.athleteID = athleteID
        self.programName = programName
        self.sport = sport.rawValue
        self.videoLocalIdentifier = videoLocalIdentifier
        self.date = date
        self.totalScore = totalScore
        self.coachNote = coachNote
        self.elements = []
    }

    var sportType: SportType {
        get { SportType(rawValue: sport) ?? .skating }
        set { sport = newValue.rawValue }
    }

    /// Calculate the total score using sport-specific rules
    var calculatedTotalScore: Double {
        elements.reduce(0) { total, element in
            total + element.calculatedScore(sport: sportType)
        }
    }
}
