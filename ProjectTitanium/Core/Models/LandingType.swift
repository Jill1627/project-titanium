import Foundation

enum LandingType: String, Codable, CaseIterable, Identifiable {
    case stuck
    case hop
    case step
    case fall

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .stuck: return "Stuck"
        case .hop: return "Hop"
        case .step: return "Step"
        case .fall: return "Fall"
        }
    }

    var isClean: Bool {
        self == .stuck
    }
}
