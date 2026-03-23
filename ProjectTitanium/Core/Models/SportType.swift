import Foundation

enum SportType: String, Codable, CaseIterable, Identifiable {
    case skating
    case gymnastics

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .skating: return "Figure Skating"
        case .gymnastics: return "Gymnastics"
        }
    }

    var iconName: String {
        switch self {
        case .skating: return "figure.skating"
        case .gymnastics: return "figure.gymnastics"
        }
    }
}
