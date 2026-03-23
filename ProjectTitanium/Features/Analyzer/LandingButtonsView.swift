import SwiftUI

struct LandingButtonsView: View {
    @Binding var selectedLanding: LandingType
    let hapticsService: HapticsService

    var body: some View {
        HStack(spacing: 12) {
            ForEach(LandingType.allCases) { landing in
                Button {
                    selectedLanding = landing
                    triggerHaptic(for: landing)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: iconName(for: landing))
                            .font(.title3)
                        Text(landing.displayName)
                            .brandFont(.medium, size: 10, relativeTo: .caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedLanding == landing ? backgroundColor(for: landing) : Color(.systemGray6))
                    )
                    .foregroundStyle(selectedLanding == landing ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func iconName(for landing: LandingType) -> String {
        switch landing {
        case .stuck: return "checkmark.circle.fill"
        case .hop: return "arrow.up.right"
        case .step: return "shoe.fill"
        case .fall: return "arrow.down.circle.fill"
        }
    }

    private func backgroundColor(for landing: LandingType) -> Color {
        landing.isClean ? Color.accentColor : .red.opacity(0.8)
    }

    private func triggerHaptic(for landing: LandingType) {
        switch landing {
        case .stuck:
            hapticsService.playStuckLanding()
        case .fall:
            hapticsService.playFall()
        case .hop, .step:
            hapticsService.playDeduction()
        }
    }
}
