import SwiftData
import SwiftUI

struct DashboardView: View {
    let athlete: Athlete
    @Query private var allRunThroughs: [RunThrough]
    @State private var viewModel: DashboardViewModel

    init(athlete: Athlete) {
        self.athlete = athlete
        self._viewModel = State(initialValue: DashboardViewModel(athlete: athlete))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Stats summary
                statsHeader

                // Heatmap
                ConsistencyHeatmapView(viewModel: viewModel)

                // Trend
                TrendSplineView(viewModel: viewModel)
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .onAppear {
            viewModel.loadData(from: allRunThroughs)
        }
        .onChange(of: allRunThroughs.count) {
            viewModel.loadData(from: allRunThroughs)
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Run-Throughs",
                value: "\(viewModel.runThroughs.count)",
                icon: "video"
            )

            StatCard(
                title: "Best Score",
                value: String(format: "%.1f", viewModel.runThroughs.map(\.totalScore).max() ?? 0),
                icon: "star"
            )

            StatCard(
                title: "Elements",
                value: "\(viewModel.runThroughs.flatMap(\.elements).count)",
                icon: "list.bullet"
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
    }
}
