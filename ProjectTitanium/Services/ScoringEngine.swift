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
