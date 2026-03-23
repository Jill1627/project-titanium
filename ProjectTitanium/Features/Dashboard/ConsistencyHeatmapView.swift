import SwiftUI

struct ConsistencyHeatmapView: View {
    let viewModel: DashboardViewModel

    private let cellSize: CGFloat = 28
    private let spacing: CGFloat = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Consistency Heatmap")
                .font(.headline)

            if viewModel.heatmapData.isEmpty {
                Text("Not enough data yet. Analyze more run-throughs to see consistency patterns.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    heatmapGrid
                }

                // Legend
                HStack(spacing: 16) {
                    legendItem(color: Color.accentColor, label: "> 80%")
                    legendItem(color: Color.yellow.opacity(0.6), label: "50-80%")
                    legendItem(color: Color.red.opacity(0.6), label: "< 50%")
                }
                .font(.caption2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
    }

    private var heatmapGrid: some View {
        let codes = viewModel.uniqueElementCodes
        let runCount = min(viewModel.runThroughs.count, 10)

        return VStack(alignment: .leading, spacing: spacing) {
            // Header row (run numbers)
            HStack(spacing: spacing) {
                Text("")
                    .frame(width: 50)
                ForEach(0..<runCount, id: \.self) { i in
                    Text("R\(i + 1)")
                        .font(.caption2)
                        .frame(width: cellSize, height: cellSize)
                }
            }

            // Data rows
            ForEach(codes, id: \.self) { code in
                HStack(spacing: spacing) {
                    Text(code)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .frame(width: 50, alignment: .leading)
                        .lineLimit(1)

                    ForEach(0..<runCount, id: \.self) { runIndex in
                        let cell = viewModel.heatmapData.first {
                            $0.elementCode == code && $0.runIndex == runIndex
                        }
                        RoundedRectangle(cornerRadius: 4)
                            .fill(cell?.color ?? Color(.systemGray5))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
        }
    }
}
