import Foundation

protocol ScoringEngine {
    var sport: SportType { get }
    func calculateScore(baseValue: Double, executionAdjustment: Double) -> Double
}

struct SkatingScoring: ScoringEngine {
    let sport = SportType.skating
    private let registry = FigureSkatingElementRegistry.shared

    // Legacy method for backward compatibility
    func calculateScore(baseValue: Double, executionAdjustment: Double) -> Double {
        // ISU Formula: baseValue + GOE adjustment (10% per level)
        let goeAdjustment = (baseValue * 0.1 * executionAdjustment).rounded(toPlaces: 2)
        return baseValue + goeAdjustment
    }

    /// Calculate score for a figure skating element with full technical calls
    /// Implements ISU 2025-2026 scoring rules exactly
    func calculateElementScore(
        elementCode: String,
        level: String?,
        goe: Int,
        rotationCall: RotationCall,
        edgeCall: EdgeCall,
        isRepeat: Bool,
        isSecondHalf: Bool,
        landing: LandingType
    ) -> (score: Double, breakdown: ScoreBreakdown) {
        guard let element = registry.element(forCode: elementCode) else {
            return (0.0, ScoreBreakdown(
                originalBase: 0.0,
                adjustedBase: 0.0,
                goeAdjustment: 0.0,
                finalScore: 0.0,
                notes: ["Unknown element code: \(elementCode)"]
            ))
        }

        var notes: [String] = []

        // Step 1: Resolve base value
        let originalBase: Double
        if element.requiresLevel {
            guard let level = level, let levelValue = element.levels?[level] else {
                return (0.0, ScoreBreakdown(
                    originalBase: 0.0,
                    adjustedBase: 0.0,
                    goeAdjustment: 0.0,
                    finalScore: 0.0,
                    notes: ["Level required for \(elementCode)"]
                ))
            }
            originalBase = levelValue
        } else {
            originalBase = element.baseValue ?? 0.0
        }

        var adjustedBase = originalBase

        // Step 2: Apply technical calls to base value (in priority order)

        // 2a. Downgrade (<<) - use lower revolution jump
        if rotationCall == .downgraded {
            if let downgradedCode = getLowerRevolutionCode(elementCode),
               let downgradedElement = registry.element(forCode: downgradedCode) {
                adjustedBase = downgradedElement.baseValue ?? originalBase
                notes.append("<< downgrade uses \(downgradedCode) base value")
            } else {
                notes.append("<< call applied but no downgrade available")
            }
        }
        // 2b. Under-rotation (<) + Edge Error (e) combination
        else if rotationCall == .underRotated && edgeCall == .wrongEdge {
            if let combinedValue = element.alternateBaseValues?.underRotatedAndEdgeError {
                adjustedBase = combinedValue
                notes.append("< + e alternate base value applied")
            } else {
                // Fall back to under-rotation only
                if let urValue = element.alternateBaseValues?.underRotated {
                    adjustedBase = urValue
                    notes.append("< alternate base value applied (no < + e value)")
                }
            }
        }
        // 2c. Under-rotation (<) alone
        else if rotationCall == .underRotated {
            if let urValue = element.alternateBaseValues?.underRotated {
                adjustedBase = urValue
                notes.append("< alternate base value applied")
            } else {
                notes.append("< call recorded but no alternate value")
            }
        }
        // 2d. Edge Error (e) alone
        else if edgeCall == .wrongEdge {
            if let edgeValue = element.alternateBaseValues?.edgeError {
                adjustedBase = edgeValue
                notes.append("e alternate base value applied")
            } else {
                notes.append("e call recorded; no alternate base value")
            }
        }
        // 2e. Edge Warning (!)
        else if edgeCall == .attention {
            notes.append("! edge warning keeps full base value")
        }
        // 2f. Quarter rotation (q)
        else if rotationCall == .quarter {
            notes.append("q call keeps full base value")
        }

        // Step 3: Apply repeat penalty (70%)
        if isRepeat {
            adjustedBase *= 0.7
            notes.append("+REP penalty applied (70%)")
        }

        // Step 4: Apply second half bonus (1.1x)
        if isSecondHalf && element.secondHalfBonusEligible {
            adjustedBase *= 1.1
            notes.append("x second-half bonus applied")
        }

        adjustedBase = adjustedBase.rounded(toPlaces: 2)

        // Step 5: Calculate GOE adjustment (use original base for GOE, not adjusted)
        let goeAdjustment = element.goeAdjustments[goe] ?? 0.0

        // Step 6: Calculate final element score
        var finalScore = adjustedBase + goeAdjustment

        // Step 7: Apply fall deduction (-1.0)
        if landing == .fall {
            finalScore -= 1.0
            notes.append("Fall deduction (-1.0)")
        }

        finalScore = max(0, finalScore.rounded(toPlaces: 2))

        let breakdown = ScoreBreakdown(
            originalBase: originalBase,
            adjustedBase: adjustedBase,
            goeAdjustment: goeAdjustment,
            finalScore: finalScore,
            notes: notes
        )

        return (finalScore, breakdown)
    }

    /// Legacy calculateElementScore with baseValue parameter
    /// Kept for backward compatibility but should migrate to elementCode version
    func calculateElementScore(
        baseValue: Double,
        goe: Double,
        rotationCall: RotationCall,
        edgeCall: EdgeCall,
        isRepeat: Bool,
        isSecondHalf: Bool,
        landing: LandingType
    ) -> Double {
        var adjustedBase = baseValue

        // Apply technical calls (simplified version)
        adjustedBase *= rotationCall.baseValueMultiplier
        adjustedBase *= edgeCall.baseValueMultiplier

        if isRepeat {
            adjustedBase *= 0.7
        }

        if isSecondHalf {
            adjustedBase *= 1.1
        }

        let goeAdjustment = (baseValue * 0.1 * goe).rounded(toPlaces: 2)
        var finalScore = adjustedBase + goeAdjustment

        if landing == .fall {
            finalScore -= 1.0
        }

        return max(0, finalScore.rounded(toPlaces: 2))
    }

    /// Get the element code for one rotation level lower
    private func getLowerRevolutionCode(_ code: String) -> String? {
        // Parse jump code (e.g., "3T" -> rotation: 3, family: "T")
        // Check if it matches jump pattern: digit followed by jump family
        guard code.range(of: #"^(\d)(T|S|Lo|F|Lz|A)$"#, options: .regularExpression) != nil else {
            return nil
        }

        let rotationChar = code[code.startIndex]
        guard let rotation = Int(String(rotationChar)), rotation > 1 else {
            return nil
        }

        let family = String(code.dropFirst())
        return "\(rotation - 1)\(family)"
    }

    struct ScoreBreakdown {
        let originalBase: Double
        let adjustedBase: Double
        let goeAdjustment: Double
        let finalScore: Double
        let notes: [String]
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
