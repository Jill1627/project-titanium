import Charts
import PhotosUI
import SwiftData
import SwiftUI

struct RunThroughListView: View {
    let athlete: Athlete
    @Environment(\.modelContext) private var modelContext
    @Query private var allRunThroughs: [RunThrough]
    @Query(sort: \PlannedProgramContent.createdAt, order: .reverse)
    private var allPPCs: [PlannedProgramContent]
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingPPCPicker = false
    @State private var pendingRun: RunThrough?

    private var runThroughs: [RunThrough] {
        allRunThroughs
            .filter { $0.athleteID == athlete.id }
            .sorted { $0.date > $1.date }
    }

    private var matchingPPCs: [PlannedProgramContent] {
        allPPCs.filter { $0.sport == athlete.sport }
    }

    var body: some View {
        Group {
            if runThroughs.isEmpty {
                ContentUnavailableView(
                    "No Run-Throughs for \(athlete.name)",
                    systemImage: "video",
                    description: Text("Import a video for analysis to get started.")
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        Text(athlete.name)
                            .headerXLStyle()
                            .foregroundStyle(Color.textPrimary)

                        // Score trend chart
                        if runThroughs.count > 1 {
                            ScoreTrendChart(runThroughs: runThroughs)
                        }

                        // Runthrough cards
                        VStack(spacing: 24) {
                            ForEach(Array(runThroughs.enumerated()), id: \.element.id) { index, run in
                                NavigationLink(value: run) {
                                    RunThroughCard(runThrough: run)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Run-Throughs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .videos
                ) {
                    Image(systemName: "plus")
                }
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            importVideo(from: newItem)
        }
        .navigationDestination(for: RunThrough.self) { runThrough in
            RunThroughDetailView(runThrough: runThrough)
        }
        .navigationDestination(for: AnalyzerDestination.self) { dest in
            AnalyzerView(viewModel: AnalyzerViewModel(
                runThrough: dest.runThrough,
                ppcElementCodes: dest.ppcCodes
            ))
        }
        .sheet(isPresented: $showingPPCPicker) {
            PPCPickerSheet(
                ppcs: matchingPPCs,
                onSelect: { ppc in
                    if let run = pendingRun {
                        // Navigate with PPC
                        showingPPCPicker = false
                        pendingRun = nil
                        // Insert run and navigate
                        modelContext.insert(run)
                    }
                },
                onSkip: {
                    if let run = pendingRun {
                        modelContext.insert(run)
                    }
                    showingPPCPicker = false
                    pendingRun = nil
                }
            )
            .presentationDetents([.medium])
        }
    }

    private func importVideo(from item: PhotosPickerItem) {
        guard let assetIdentifier = item.itemIdentifier else { return }

        let sport = SportType(rawValue: athlete.sport) ?? .skating
        let run = RunThrough(
            athleteID: athlete.id,
            programName: "Untitled Program",
            sport: sport,
            videoLocalIdentifier: assetIdentifier
        )
        modelContext.insert(run)
        selectedItem = nil
    }
}

struct AnalyzerDestination: Hashable {
    let runThrough: RunThrough
    let ppcCodes: [String]
}

struct PPCPickerSheet: View {
    let ppcs: [PlannedProgramContent]
    let onSelect: (PlannedProgramContent) -> Void
    let onSkip: () -> Void

    var body: some View {
        NavigationStack {
            List(ppcs) { ppc in
                Button {
                    onSelect(ppc)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ppc.name)
                            .font(.headline)
                        Text("\(ppc.elementCodes.count) elements")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Load Program")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip", action: onSkip)
                }
            }
        }
    }
}

struct ScoreTrendChart: View {
    @Environment(\.theme) var theme
    let runThroughs: [RunThrough]

    private var chartData: [(date: Date, score: Double)] {
        runThroughs
            .sorted { $0.date < $1.date }
            .map { (date: $0.date, score: $0.calculatedTotalScore) }
    }

    private var maxScore: Double {
        chartData.map(\.score).max() ?? 50
    }

    private var minScore: Double {
        chartData.map(\.score).min() ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text("SCORE TREND")
                .labelCapsStyle()
                .foregroundStyle(Color.textPrimary)

            // Chart
            Chart(chartData, id: \.date) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Score", item.score)
                )
                .foregroundStyle(theme.primary)
                .lineStyle(StrokeStyle(lineWidth: 3))

                PointMark(
                    x: .value("Date", item.date),
                    y: .value("Score", item.score)
                )
                .foregroundStyle(theme.primary)
                .symbol {
                    Circle()
                        .fill(.black)
                        .frame(width: 8, height: 8)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(Color.borderSubtle.opacity(0.5))
                    AxisValueLabel()
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .chartYScale(domain: (minScore * 0.9)...(maxScore * 1.1))
            .frame(height: 180)
        }
        .padding(20)
        .background(Color.surfaceCardSubtle, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderSubtle, lineWidth: 1)
        )
    }
}

struct RunThroughCard: View {
    @Environment(\.theme) var theme
    let runThrough: RunThrough

    private var landingCounts: [(LandingType, Int)] {
        let grouped = Dictionary(grouping: runThrough.elements) { $0.landingType }
        return LandingType.allCases
            .compactMap { type in
                guard let count = grouped[type]?.count, count > 0, type != .stuck else { return nil }
                return (type, count)
            }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Left: Info section
            VStack(alignment: .leading, spacing: 10) {
                // Date
                Text(runThrough.date.formatted(date: .abbreviated, time: .omitted).uppercased())
                    .labelCapsStyle()
                    .foregroundStyle(Color.textSecondary)

                // Program name
                Text(runThrough.programName)
                    .headerLGStyle()
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                // Element count and badges
                HStack(spacing: 8) {
                    Text("\(runThrough.elements.count) elements")
                        .bodyMDStyle()
                        .foregroundStyle(Color.textTertiary)

                    ForEach(landingCounts, id: \.0) { landing, count in
                        LandingBadge(landing: landing, count: count)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Score Badge
            VStack(spacing: 2) {
                Text(String(format: "%.2f", runThrough.calculatedTotalScore))
                    .scoreMediumStyle()
                    .foregroundStyle(theme.primary)
                
                Text("PTS")
                    .labelCapsStyle(isWider: true)
                    .font(.system(size: 9))
                    .foregroundStyle(Color.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(theme.primary.opacity(0.08))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(theme.primary.opacity(0.15), lineWidth: 1)
            )
        }
        .titaniumCardStyle(hasBloom: true)
    }
}

struct LandingBadge: View {
    let landing: LandingType
    let count: Int

    var backgroundColor: Color {
        switch landing {
        case .stuck:
            return Color(hex: "FFE712") // warning-badge
        case .fall:
            return Color(hex: "EF4444") // error-primary
        case .hop, .step:
            return Color(hex: "F3F4F6") // neutral-badge
        }
    }

    var textColor: Color {
        switch landing {
        case .fall:
            return .white
        default:
            return .black
        }
    }

    var body: some View {
        Text("\(count) \(landing.displayName.uppercased())")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(8)
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
