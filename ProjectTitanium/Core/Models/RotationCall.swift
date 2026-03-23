import Foundation

/// ISU Figure Skating Rotation Call
/// Controls how under-rotation affects base value through alternate values
enum RotationCall: String, Codable, CaseIterable, Identifiable {
    case clean = ""           // No call - full rotation, full base value
    case underRotated = "<"   // 1/4 to 1/2 turn short - uses alternate base value
    case quarter = "q"        // Exactly 1/4 turn short - keeps base, GOE capped at +2
    case downgraded = "<<"    // More than 1/2 turn short - uses lower revolution base

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .clean: return "Clean"
        case .underRotated: return "Under-rotated (<)"
        case .quarter: return "Quarter (q)"
        case .downgraded: return "Downgraded (<<)"
        }
    }

    var description: String {
        switch self {
        case .clean:
            return "Full rotation completed"
        case .underRotated:
            return "Under-rotated by 1/4 to 1/2 turn; uses alternate base value (typically 80% of full)"
        case .quarter:
            return "Exactly 1/4 turn short; keeps full base value but GOE capped at +2"
        case .downgraded:
            return "More than 1/2 turn short; scored as jump with one less rotation"
        }
    }

    /// Legacy multiplier - deprecated, use alternate base values from element registry
    @available(*, deprecated, message: "Use FigureSkatingElementRegistry alternate base values instead")
    var baseValueMultiplier: Double {
        switch self {
        case .clean: return 1.0
        case .underRotated: return 0.8  // Approximate - actual values vary by element
        case .quarter: return 1.0
        case .downgraded: return 1.0
        }
    }
}
