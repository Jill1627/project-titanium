import Foundation

enum RotationCall: String, Codable, CaseIterable, Identifiable {
    case clean = ""           // No call - full rotation
    case underRotated = "<"   // 1/4 to 1/2 turn short - 70% base value
    case quarter = "q"        // Exactly 1/4 turn short - 100% base, reduced GOE
    case downgraded = "<<"    // More than 1/2 turn short - one fewer rotation

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .clean: return "Clean"
        case .underRotated: return "Under-rotated (<)"
        case .quarter: return "Quarter (q)"
        case .downgraded: return "Downgraded (<<)"
        }
    }

    var baseValueMultiplier: Double {
        switch self {
        case .clean: return 1.0
        case .underRotated: return 0.7
        case .quarter: return 1.0
        case .downgraded: return 1.0 // Will be handled by rotation reduction
        }
    }
}
