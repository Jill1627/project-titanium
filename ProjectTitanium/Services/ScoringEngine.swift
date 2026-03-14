import Foundation

protocol ScoringEngine {
    var sport: SportType { get }
    func calculateScore(baseValue: Double, executionAdjustment: Double) -> Double
}

struct SkatingScoring: ScoringEngine {
    let sport = SportType.skating

    // Skating: baseValue + (GOE x scaleFactor)
    // Scale factor varies by element; using 1.0 as default for MVP
    func calculateScore(baseValue: Double, executionAdjustment: Double) -> Double {
        baseValue + (executionAdjustment * scaleFactor(for: baseValue))
    }

    private func scaleFactor(for baseValue: Double) -> Double {
        // Simplified: higher base value elements have larger GOE impact
        if baseValue >= 8.0 { return 1.0 }
        if baseValue >= 4.0 { return 0.7 }
        return 0.5
    }

    /// Calculate score for a figure skating element with full technical calls
    func calculateElementScore(
        baseValue: Double,
        goe: Double,
        rotationCall: RotationCall,
        edgeCall: EdgeCall,
        isRepeat: Bool,
        isSecondHalf: Bool,
        landing: LandingType
    ) -> Double {
        // Step 1: Apply rotation call modifier
        var effectiveBase = baseValue

        // Handle downgrade - reduces by one rotation level
        if rotationCall == .downgraded {
            effectiveBase = getDowngradedValue(baseValue)
        }

        // Step 2: Apply rotation base value multipliers
        effectiveBase *= rotationCall.baseValueMultiplier

        // Step 3: Apply edge call multiplier
        effectiveBase *= edgeCall.baseValueMultiplier

        // Step 4: Apply repeat penalty (70%)
        if isRepeat {
            effectiveBase *= 0.7
        }

        // Step 5: Apply second half bonus (1.1x)
        if isSecondHalf {
            effectiveBase *= 1.1
        }

        // Step 6: Calculate GOE contribution
        let goeValue = goe * scaleFactor(for: baseValue)

        // Step 7: Final score (base + GOE)
        var finalScore = effectiveBase + goeValue

        // Step 8: Apply fall deduction (-1.0 per fall, handled at element level)
        if landing == .fall {
            finalScore -= 1.0
        }

        return max(0, finalScore)
    }

    /// Get the downgraded base value (one rotation level lower)
    /// This is a simplified mapping - in reality would use a jump table
    private func getDowngradedValue(_ originalBase: Double) -> Double {
        // Example: 4T (9.5) -> 3T (4.2), 3A (8.0) -> 2A (3.3)
        // This would ideally be a lookup table based on element code
        // For now, use a simplified reduction
        switch originalBase {
        case 12.0...15.0: return originalBase * 0.45  // Quad -> Triple
        case 8.0...12.0: return originalBase * 0.50   // Triple -> Double
        case 4.0...8.0: return originalBase * 0.40    // Double -> Single
        default: return originalBase * 0.30
        }
    }
}

struct GymnasticsScoring: ScoringEngine {
    let sport = SportType.gymnastics

    // Gymnastics: DScore - sum(deductions)
    func calculateScore(baseValue: Double, executionAdjustment: Double) -> Double {
        max(0, baseValue + executionAdjustment) // executionAdjustment is negative for deductions
    }
}

enum ScoringEngineFactory {
    static func engine(for sport: SportType) -> ScoringEngine {
        switch sport {
        case .skating: return SkatingScoring()
        case .gymnastics: return GymnasticsScoring()
        }
    }
}
