import Foundation
import SwiftData

@Model
final class ElementScore {
    var id: UUID
    var elementCode: String
    var timestamp: Double
    var executionValue: Double // GOE value (-5 to +5)
    var landing: String // LandingType rawValue
    var coachNote: String?
    var createdAt: Date

    // Figure skating technical calls
    var baseValue: Double = 0.0 // Base value of the element
    var rotationCall: String = "" // RotationCall rawValue (default: clean)
    var edgeCall: String = "" // EdgeCall rawValue (default: correct)
    var isRepeat: Bool = false // +REP flag (70% base value)
    var isSecondHalf: Bool = false // Second half bonus (1.1x multiplier)

    @Relationship(inverse: \RunThrough.elements)
    var runThrough: RunThrough?

    init(
        elementCode: String,
        timestamp: Double,
        executionValue: Double = 0.0,
        landing: LandingType = .stuck,
        coachNote: String? = nil,
        baseValue: Double = 0.0,
        rotationCall: RotationCall = .clean,
        edgeCall: EdgeCall = .correct,
        isRepeat: Bool = false,
        isSecondHalf: Bool = false
    ) {
        self.id = UUID()
        self.elementCode = elementCode
        self.timestamp = timestamp
        self.executionValue = executionValue
        self.landing = landing.rawValue
        self.coachNote = coachNote
        self.createdAt = Date()
        self.baseValue = baseValue
        self.rotationCall = rotationCall.rawValue
        self.edgeCall = edgeCall.rawValue
        self.isRepeat = isRepeat
        self.isSecondHalf = isSecondHalf
    }

    var landingType: LandingType {
        get { LandingType(rawValue: landing) ?? .stuck }
        set { landing = newValue.rawValue }
    }

    var rotationCallType: RotationCall {
        get { RotationCall(rawValue: rotationCall) ?? .clean }
        set { rotationCall = newValue.rawValue }
    }

    var edgeCallType: EdgeCall {
        get { EdgeCall(rawValue: edgeCall) ?? .correct }
        set { edgeCall = newValue.rawValue }
    }

    /// Calculate the final score for this element using figure skating rules
    func calculatedScore(sport: SportType) -> Double {
        guard sport == .skating else {
            // Fallback for non-skating sports
            return baseValue + executionValue
        }

        let engine = SkatingScoring()
        return engine.calculateElementScore(
            baseValue: baseValue,
            goe: executionValue,
            rotationCall: rotationCallType,
            edgeCall: edgeCallType,
            isRepeat: isRepeat,
            isSecondHalf: isSecondHalf,
            landing: landingType
        )
    }
}
