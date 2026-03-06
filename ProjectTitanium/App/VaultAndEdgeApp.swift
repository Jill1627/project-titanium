import SwiftData
import SwiftUI

@main
struct VaultAndEdgeApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .modelContainer(for: [
            Athlete.self,
            RunThrough.self,
            ElementScore.self,
            PlannedProgramContent.self,
        ])
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            AthleteListView()
                .tabItem {
                    Label("Athletes", systemImage: "person.3")
                }

            PPCEditorView()
                .tabItem {
                    Label("Programs", systemImage: "list.clipboard")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
