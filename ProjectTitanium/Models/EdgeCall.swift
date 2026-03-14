import Foundation

enum EdgeCall: String, Codable, CaseIterable, Identifiable {
    case correct = ""         // Correct edge
    case attention = "!"      // Unclear edge - reduced GOE
    case wrongEdge = "e"      // Wrong edge - 70% base value

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .correct: return "Correct"
        case .attention: return "Attention (!)"
        case .wrongEdge: return "Wrong Edge (e)"
        }
    }

    var baseValueMultiplier: Double {
        switch self {
        case .correct: return 1.0
        case .attention: return 1.0 // No base reduction, GOE only
        case .wrongEdge: return 0.7  // Reduced to 70%
        }
    }
}
