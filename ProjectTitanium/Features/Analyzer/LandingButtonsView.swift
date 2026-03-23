import SwiftUI

struct LandingButtonsView: View {
    @Environment(\.theme) var theme
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
                            .font(.system(size: 16, weight: .bold))
                        Text(landing.displayName)
                            .labelCapsStyle()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            if selectedLanding == landing {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(theme.shadow.opacity(0.4))
                                    .offset(x: 3, y: 3)
                            }
                            
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedLanding == landing ? backgroundColor(for: landing) : Color.surfaceInput)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(selectedLanding == landing ? Color.borderDefault : Color.clear, lineWidth: 1.5)
                    )
                    .foregroundStyle(selectedLanding == landing ? .white : Color.textPrimary)
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
        landing.isClean ? theme.primary : .red.opacity(0.8)
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
