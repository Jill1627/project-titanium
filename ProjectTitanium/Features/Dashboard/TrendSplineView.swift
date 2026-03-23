import Charts
import SwiftUI

struct TrendSplineView: View {
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score Trend")
                .font(.headline)

            if viewModel.trendData.count < 2 {
                Text("Analyze at least 2 run-throughs to see score trends.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 200)
            } else {
                Chart(viewModel.trendData) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Score", point.totalScore)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.accentColor)

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Score", point.totalScore)
                    )
                    .foregroundStyle(Color.accentColor)

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Score", point.totalScore)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
    }
}
