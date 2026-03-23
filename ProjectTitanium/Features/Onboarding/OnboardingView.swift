import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedSport") private var selectedSport = SportType.skating.rawValue
    @State private var selection: SportType = .skating

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 12) {
                Text("Vault & Edge")
                    .scoreMediumStyle()

                Text("Video analysis for coaches")
                    .bodyLGStyle()
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                Text("Choose your sport")
                    .headerSMStyle()

                ForEach(SportType.allCases) { sport in
                    SportSelectionCard(
                        sport: sport,
                        isSelected: selection == sport
                    ) {
                        selection = sport
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            Button {
                selectedSport = selection.rawValue
                hasCompletedOnboarding = true
            } label: {
                Text("Get Started")
                    .headerSMStyle()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentMint)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

struct SportSelectionCard: View {
    let sport: SportType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: sport.iconName)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(sport.displayName)
                    .bodyLGStyle()

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView()
}
