import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("selectedSport") private var selectedSport = SportType.skating.rawValue

    private var currentSport: SportType {
        get { SportType(rawValue: selectedSport) ?? .skating }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Sport") {
                    ForEach(SportType.allCases) { sport in
                        Button {
                            selectedSport = sport.rawValue
                        } label: {
                            HStack {
                                Label(sport.displayName, systemImage: sport.iconName)
                                Spacer()
                                if sport.rawValue == selectedSport {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Section("App") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button("Reset Onboarding") {
                        hasCompletedOnboarding = false
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
