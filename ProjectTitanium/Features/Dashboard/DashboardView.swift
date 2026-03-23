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
            VStack(spacing: 24) {
                // Inline Screen Header
                HStack {
                    Text("Dashboard")
                        .headerXLStyle()
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                }
                .padding(.top, 40)

                statsHeader

                ConsistencyHeatmapView(viewModel: viewModel)
                    .padding(.top, 8)

                TrendSplineView(viewModel: viewModel)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 16)
        }
        .background(Color.surfacePage)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadData(from: allRunThroughs)
        }
        .onChange(of: allRunThroughs.count) {
            viewModel.loadData(from: allRunThroughs)
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Run-Throughs",
                value: "\(viewModel.runThroughs.count)",
                icon: "video"
            )

            StatCard(
                title: "Best",
                value: String(format: "%.1f", viewModel.runThroughs.map(\.totalScore).max() ?? 0),
                icon: "star.fill"
            )

            StatCard(
                title: "Elements",
                value: "\(viewModel.runThroughs.flatMap(\.elements).count)",
                icon: "circle.grid.3x3.fill"
            )
        }
    }
}

struct StatCard: View {
    @Environment(\.theme) var theme
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(theme.primary)
                .padding(.bottom, 4)

            Text(value)
                .headerMDStyle()
                .foregroundStyle(Color.textPrimary)

            Text(title)
                .captionStyle()
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.shadow.opacity(0.6))
                    .offset(x: 4, y: 4)

                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceCard)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.border.opacity(0.4), lineWidth: 1.5)
        )
    }
}
