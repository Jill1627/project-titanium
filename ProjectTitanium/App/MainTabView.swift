import SwiftUI

struct MainTabView: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        TabView {
            AthleteListView()
                .tabItem {
                    Label("Athletes", systemImage: "person.3")
                }
            
            // PPCEditorView()
            //     .tabItem {
            //         Label("Programs", systemImage: "list.clipboard")
            //     }
           
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(theme.primary)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .systemBackground
            
            // Unselected state - gray
            appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
            
            // Selected state - primary from theme
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(theme.primary)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(theme.primary)]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
