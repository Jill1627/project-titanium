import SwiftUI
import SwiftData

@main
struct VaultAndEdgeApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedSport") private var selectedSport = SportType.skating.rawValue

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                AthleteListView()
            } else {
                OnboardingView()
            }
        }
        .modelContainer(for: [Athlete.self, RunThrough.self, ElementScore.self])
    }
}
