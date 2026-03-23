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
    var baseValue: Double = 0.0 // Base value of the element (for display/legacy)
    var level: String? = nil // Level for spins/sequences (LB, L1, L2, L3, L4)
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
        level: String? = nil,
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
        self.level = level
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

    /// Calculate the final score for this element using ISU 2025-2026 rules
    func calculatedScore(sport: SportType) -> Double {
        guard sport == .skating else {
            // Fallback for non-skating sports
            return baseValue + executionValue
        }

        let engine = SkatingScoring()
        let goeInt = Int(executionValue.rounded())

        // Use ISU-compliant scoring with element registry
        let result = engine.calculateElementScore(
            elementCode: elementCode,
            level: level,
            goe: goeInt,
            rotationCall: rotationCallType,
            edgeCall: edgeCallType,
            isRepeat: isRepeat,
            isSecondHalf: isSecondHalf,
            landing: landingType
        )

        return result.score
    }

    /// Get detailed scoring breakdown for this element
    func scoreBreakdown(sport: SportType) -> SkatingScoring.ScoreBreakdown? {
        guard sport == .skating else { return nil }

        let engine = SkatingScoring()
        let goeInt = Int(executionValue.rounded())

        let result = engine.calculateElementScore(
            elementCode: elementCode,
            level: level,
            goe: goeInt,
            rotationCall: rotationCallType,
            edgeCall: edgeCallType,
            isRepeat: isRepeat,
            isSecondHalf: isSecondHalf,
            landing: landingType
        )

        return result.breakdown
    }
}
