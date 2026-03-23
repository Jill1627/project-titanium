import Foundation

/// ISU 2025-2026 Figure Skating Element Definition
struct FigureSkatingElement {
    let code: String
    let name: String
    let category: ElementCategory
    let baseValue: Double?
    let levels: [String: Double]?
    let goeAdjustments: [Int: Double]
    let alternateBaseValues: AlternateBaseValues?
    let secondHalfBonusEligible: Bool
    let requiresLevel: Bool
    let allowedModifiers: [String]

    struct AlternateBaseValues {
        let underRotated: Double?      // <
        let edgeError: Double?          // e
        let underRotatedAndEdgeError: Double?  // < + e
        let v: Double?                  // V (for spins)
    }

    enum ElementCategory: String {
        case jump
        case spin
        case stepSequence
        case choreographicSequence
    }
}

/// ISU 2025-2026 Singles Element Registry
/// Derived from official ISU Singles SOV/GOE Dataset
struct FigureSkatingElementRegistry {

    static let shared = FigureSkatingElementRegistry()

    private let elements: [String: FigureSkatingElement]

    private init() {
        var registry: [String: FigureSkatingElement] = [:]

        // MARK: - Single Jumps
        registry["1T"] = FigureSkatingElement(
            code: "1T",
            name: "Single Toe Loop",
            category: .jump,
            baseValue: 0.4,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 0.4),
            alternateBaseValues: nil,
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["1S"] = FigureSkatingElement(
            code: "1S",
            name: "Single Salchow",
            category: .jump,
            baseValue: 0.4,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 0.4),
            alternateBaseValues: nil,
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["1Lo"] = FigureSkatingElement(
            code: "1Lo",
            name: "Single Loop",
            category: .jump,
            baseValue: 0.5,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 0.5),
            alternateBaseValues: nil,
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["1F"] = FigureSkatingElement(
            code: "1F",
            name: "Single Flip",
            category: .jump,
            baseValue: 0.5,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 0.5),
            alternateBaseValues: nil,
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<", "e", "!"]
        )

        registry["1Lz"] = FigureSkatingElement(
            code: "1Lz",
            name: "Single Lutz",
            category: .jump,
            baseValue: 0.6,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 0.6),
            alternateBaseValues: nil,
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<", "e", "!"]
        )

        // MARK: - Double Jumps
        registry["2T"] = FigureSkatingElement(
            code: "2T",
            name: "Double Toe Loop",
            category: .jump,
            baseValue: 1.3,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 1.3),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 1.04,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["2S"] = FigureSkatingElement(
            code: "2S",
            name: "Double Salchow",
            category: .jump,
            baseValue: 1.3,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 1.3),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 1.04,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["2Lo"] = FigureSkatingElement(
            code: "2Lo",
            name: "Double Loop",
            category: .jump,
            baseValue: 1.7,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 1.7),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 1.36,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["2F"] = FigureSkatingElement(
            code: "2F",
            name: "Double Flip",
            category: .jump,
            baseValue: 1.8,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 1.8),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 1.44,
                edgeError: nil,
                underRotatedAndEdgeError: 1.08,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<", "e", "!"]
        )

        registry["2Lz"] = FigureSkatingElement(
            code: "2Lz",
            name: "Double Lutz",
            category: .jump,
            baseValue: 2.1,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 2.1),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 1.68,
                edgeError: nil,
                underRotatedAndEdgeError: 1.26,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<", "e", "!"]
        )

        registry["2A"] = FigureSkatingElement(
            code: "2A",
            name: "Double Axel",
            category: .jump,
            baseValue: 3.3,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 3.3),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 2.64,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        // MARK: - Triple Jumps
        registry["3T"] = FigureSkatingElement(
            code: "3T",
            name: "Triple Toe Loop",
            category: .jump,
            baseValue: 4.2,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 4.2),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 3.36,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["3S"] = FigureSkatingElement(
            code: "3S",
            name: "Triple Salchow",
            category: .jump,
            baseValue: 4.3,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 4.3),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 3.44,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["3Lo"] = FigureSkatingElement(
            code: "3Lo",
            name: "Triple Loop",
            category: .jump,
            baseValue: 4.9,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 4.9),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 3.92,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["3F"] = FigureSkatingElement(
            code: "3F",
            name: "Triple Flip",
            category: .jump,
            baseValue: 5.3,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 5.3),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 4.24,
                edgeError: nil,
                underRotatedAndEdgeError: 3.18,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<", "e", "!"]
        )

        registry["3Lz"] = FigureSkatingElement(
            code: "3Lz",
            name: "Triple Lutz",
            category: .jump,
            baseValue: 5.9,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 5.9),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 4.72,
                edgeError: nil,
                underRotatedAndEdgeError: 3.54,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<", "e", "!"]
        )

        registry["3A"] = FigureSkatingElement(
            code: "3A",
            name: "Triple Axel",
            category: .jump,
            baseValue: 8.0,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 8.0),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 6.4,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        // MARK: - Quad Jumps
        registry["4T"] = FigureSkatingElement(
            code: "4T",
            name: "Quad Toe Loop",
            category: .jump,
            baseValue: 9.5,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 9.5),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 7.6,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["4S"] = FigureSkatingElement(
            code: "4S",
            name: "Quad Salchow",
            category: .jump,
            baseValue: 9.7,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 9.7),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 7.76,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["4Lo"] = FigureSkatingElement(
            code: "4Lo",
            name: "Quad Loop",
            category: .jump,
            baseValue: 10.5,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 10.5),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 8.4,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        registry["4F"] = FigureSkatingElement(
            code: "4F",
            name: "Quad Flip",
            category: .jump,
            baseValue: 11.0,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 11.0),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 8.8,
                edgeError: nil,
                underRotatedAndEdgeError: 6.6,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<", "e", "!"]
        )

        registry["4Lz"] = FigureSkatingElement(
            code: "4Lz",
            name: "Quad Lutz",
            category: .jump,
            baseValue: 11.5,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 11.5),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 9.2,
                edgeError: nil,
                underRotatedAndEdgeError: 6.9,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<", "e", "!"]
        )

        registry["4A"] = FigureSkatingElement(
            code: "4A",
            name: "Quad Axel",
            category: .jump,
            baseValue: 12.5,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 12.5),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: 10.0,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: nil
            ),
            secondHalfBonusEligible: true,
            requiresLevel: false,
            allowedModifiers: ["x", "q", "<", "<<"]
        )

        // MARK: - Spins
        registry["USp"] = FigureSkatingElement(
            code: "USp",
            name: "Upright Spin",
            category: .spin,
            baseValue: nil,
            levels: ["LB": 1.0, "L1": 1.2, "L2": 1.5, "L3": 1.9, "L4": 2.4],
            goeAdjustments: Self.buildGOE(base: 2.4), // Use L4 for GOE calculation
            alternateBaseValues: nil,
            secondHalfBonusEligible: false,
            requiresLevel: true,
            allowedModifiers: []
        )

        registry["LSp"] = FigureSkatingElement(
            code: "LSp",
            name: "Layback Spin",
            category: .spin,
            baseValue: nil,
            levels: ["LB": 1.2, "L1": 1.5, "L2": 1.9, "L3": 2.4, "L4": 2.7],
            goeAdjustments: Self.buildGOE(base: 2.7),
            alternateBaseValues: nil,
            secondHalfBonusEligible: false,
            requiresLevel: true,
            allowedModifiers: []
        )

        registry["CSp"] = FigureSkatingElement(
            code: "CSp",
            name: "Camel Spin",
            category: .spin,
            baseValue: nil,
            levels: ["LB": 1.1, "L1": 1.4, "L2": 1.8, "L3": 2.3, "L4": 2.6],
            goeAdjustments: Self.buildGOE(base: 2.6),
            alternateBaseValues: nil,
            secondHalfBonusEligible: false,
            requiresLevel: true,
            allowedModifiers: []
        )

        registry["SSp"] = FigureSkatingElement(
            code: "SSp",
            name: "Sit Spin",
            category: .spin,
            baseValue: nil,
            levels: ["LB": 1.1, "L1": 1.3, "L2": 1.6, "L3": 2.1, "L4": 2.5],
            goeAdjustments: Self.buildGOE(base: 2.5),
            alternateBaseValues: nil,
            secondHalfBonusEligible: false,
            requiresLevel: true,
            allowedModifiers: []
        )

        registry["CCSp"] = FigureSkatingElement(
            code: "CCSp",
            name: "Camel Spin Change Foot",
            category: .spin,
            baseValue: nil,
            levels: ["LB": 1.7, "L1": 2.0, "L2": 2.3, "L3": 2.8, "L4": 3.2],
            goeAdjustments: Self.buildGOE(base: 3.2),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: nil,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: 1.28
            ),
            secondHalfBonusEligible: false,
            requiresLevel: true,
            allowedModifiers: ["V"]
        )

        registry["CCoSp"] = FigureSkatingElement(
            code: "CCoSp",
            name: "Combination Spin Change Foot",
            category: .spin,
            baseValue: nil,
            levels: ["LB": 1.7, "L1": 2.0, "L2": 2.5, "L3": 3.0, "L4": 3.5],
            goeAdjustments: Self.buildGOE(base: 3.5),
            alternateBaseValues: FigureSkatingElement.AlternateBaseValues(
                underRotated: nil,
                edgeError: nil,
                underRotatedAndEdgeError: nil,
                v: 1.28
            ),
            secondHalfBonusEligible: false,
            requiresLevel: true,
            allowedModifiers: ["V"]
        )

        // MARK: - Step Sequences
        registry["StSq"] = FigureSkatingElement(
            code: "StSq",
            name: "Step Sequence",
            category: .stepSequence,
            baseValue: nil,
            levels: ["LB": 1.5, "L1": 1.8, "L2": 2.6, "L3": 3.3, "L4": 3.9],
            goeAdjustments: Self.buildGOE(base: 3.9),
            alternateBaseValues: nil,
            secondHalfBonusEligible: false,
            requiresLevel: true,
            allowedModifiers: []
        )

        registry["ChSq"] = FigureSkatingElement(
            code: "ChSq",
            name: "Choreographic Sequence",
            category: .choreographicSequence,
            baseValue: 3.0,
            levels: nil,
            goeAdjustments: Self.buildGOE(base: 3.0),
            alternateBaseValues: nil,
            secondHalfBonusEligible: false,
            requiresLevel: false,
            allowedModifiers: []
        )

        self.elements = registry
    }

    /// Build GOE adjustments table (±10% of base value per GOE level)
    private static func buildGOE(base: Double) -> [Int: Double] {
        let increment = (base * 0.1).rounded(toPlaces: 2)
        return [
            -5: -increment * 5,
            -4: -increment * 4,
            -3: -increment * 3,
            -2: -increment * 2,
            -1: -increment * 1,
            0: 0.0,
            1: increment * 1,
            2: increment * 2,
            3: increment * 3,
            4: increment * 4,
            5: increment * 5
        ]
    }

    func element(forCode code: String) -> FigureSkatingElement? {
        elements[code]
    }

    var allElements: [FigureSkatingElement] {
        Array(elements.values).sorted { $0.code < $1.code }
    }
}

// MARK: - Helper Extensions
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
