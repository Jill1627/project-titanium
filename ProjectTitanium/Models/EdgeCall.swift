import Foundation

/// ISU Figure Skating Edge Call
/// Applies only to Flip (F) and Lutz (Lz) jumps
enum EdgeCall: String, Codable, CaseIterable, Identifiable {
    case correct = ""         // Correct edge - full base value
    case attention = "!"      // Unclear edge - full base, negative GOE
    case wrongEdge = "e"      // Wrong edge - uses alternate base value

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .correct: return "Correct"
        case .attention: return "Attention (!)"
        case .wrongEdge: return "Wrong Edge (e)"
        }
    }

    var description: String {
        switch self {
        case .correct:
            return "Correct edge"
        case .attention:
            return "Edge uncertain; keeps full base value but negative GOE"
        case .wrongEdge:
            return "Wrong edge; may use alternate base value if defined"
        }
    }

    /// Legacy multiplier - deprecated, use alternate base values from element registry
    @available(*, deprecated, message: "Use FigureSkatingElementRegistry alternate base values instead")
    var baseValueMultiplier: Double {
        switch self {
        case .correct: return 1.0
        case .attention: return 1.0
        case .wrongEdge: return 1.0  // Handled by alternate values in registry
        }
    }
}
