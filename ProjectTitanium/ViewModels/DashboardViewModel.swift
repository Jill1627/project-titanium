import SwiftData
import SwiftUI

@Observable
final class DashboardViewModel {
    var athlete: Athlete
    var runThroughs: [RunThrough] = []

    init(athlete: Athlete) {
        self.athlete = athlete
    }

    func loadData(from allRunThroughs: [RunThrough]) {
        runThroughs = allRunThroughs
            .filter { $0.athleteID == athlete.id }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Heatmap Data

    struct HeatmapCell: Identifiable {
        let id = UUID()
        let elementCode: String
        let runIndex: Int
        let executionValue: Double
        let maxPossible: Double

        var ratio: Double {
            guard maxPossible > 0 else { return 0 }
            return executionValue / maxPossible
        }

        var color: Color {
            if ratio > 0.8 { return Color.accentColor }       // Mint — good
            if ratio > 0.5 { return Color.yellow.opacity(0.6) } // Mid
            return Color.red.opacity(0.6)                        // Coral — needs work
        }
    }

    var heatmapData: [HeatmapCell] {
        let recentRuns = Array(runThroughs.suffix(10))
        var cells: [HeatmapCell] = []

        // Collect all unique element codes
        let allCodes = Set(recentRuns.flatMap { $0.elements.map(\.elementCode) })

        // Find max execution value per element code
        var maxValues: [String: Double] = [:]
        for code in allCodes {
            let values = recentRuns.flatMap { $0.elements.filter { $0.elementCode == code }.map(\.executionValue) }
            maxValues[code] = values.max() ?? 1.0
        }

        for (runIndex, run) in recentRuns.enumerated() {
            for code in allCodes.sorted() {
                let element = run.elements.first { $0.elementCode == code }
                let value = element?.executionValue ?? 0
                cells.append(HeatmapCell(
                    elementCode: code,
                    runIndex: runIndex,
                    executionValue: value,
                    maxPossible: max(maxValues[code] ?? 1.0, 1.0)
                ))
            }
        }

        return cells
    }

    var uniqueElementCodes: [String] {
        let recentRuns = Array(runThroughs.suffix(10))
        return Set(recentRuns.flatMap { $0.elements.map(\.elementCode) }).sorted()
    }

    // MARK: - Trend Data

    struct TrendPoint: Identifiable {
        let id = UUID()
        let date: Date
        let totalScore: Double
    }

    var trendData: [TrendPoint] {
        runThroughs.map { TrendPoint(date: $0.date, totalScore: $0.totalScore) }
    }
}
