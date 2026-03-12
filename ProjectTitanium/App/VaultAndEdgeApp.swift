import SwiftData
import SwiftUI

@main
struct VaultAndEdgeApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    let modelContainer: ModelContainer = {
        let schema = Schema([
            Athlete.self,
            RunThrough.self,
            ElementScore.self,
            PlannedProgramContent.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Seed data in DEBUG mode
            #if DEBUG
            print("🌱 Checking for seed data...")
            SeedDataService.seedMockData(modelContext: container.mainContext)
            #endif

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .modelContainer(modelContainer)
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
