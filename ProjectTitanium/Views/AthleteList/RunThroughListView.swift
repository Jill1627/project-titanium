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
                    "No Run-Throughs",
                    systemImage: "video",
                    description: Text("Import a video from your photo library to analyze.")
                )
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Score trend chart
                        if runThroughs.count > 1 {
                            ScoreTrendChart(runThroughs: runThroughs)
                        }

                        // Runthrough cards
                        ForEach(Array(runThroughs.enumerated()), id: \.element.id) { index, run in
                            NavigationLink(value: run) {
                                BrutalistRunThroughCard(
                                    runThrough: run,
                                    colorIndex: index
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle(athlete.name)
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
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(.black)

            // Chart
            Chart(chartData, id: \.date) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Score", item.score)
                )
                .foregroundStyle(.black)
                .lineStyle(StrokeStyle(lineWidth: 3))

                PointMark(
                    x: .value("Date", item.date),
                    y: .value("Score", item.score)
                )
                .foregroundStyle(.black)
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
                        .foregroundStyle(.black)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(Color.black.opacity(0.1))
                    AxisValueLabel()
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
            .chartYScale(domain: (minScore * 0.9)...(maxScore * 1.1))
            .frame(height: 180)
        }
        .padding(20)
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 2)
        )
        .shadow(color: .black, radius: 0, x: 6, y: 6)
    }
}

struct BrutalistRunThroughCard: View {
    let runThrough: RunThrough
    let colorIndex: Int

    private var rotations: [Double] {
        [-1.5, 1.2, -0.8, 1.8, -1.2]
    }

    private var rotation: Double {
        rotations[colorIndex % rotations.count]
    }

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
            VStack(alignment: .leading, spacing: 12) {
                // Date
                Text(runThrough.date.formatted(date: .abbreviated, time: .omitted).uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.black)

                // Program name
                Text(runThrough.programName)
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(.black)
                    .lineLimit(2)

                // Element count and badges
                HStack(spacing: 8) {
                    Text("\(runThrough.elements.count) elements")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.black)

                    ForEach(landingCounts, id: \.0) { landing, count in
                        LandingBadge(landing: landing, count: count)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right: Score badge
            VStack {
                Text(String(format: "%.2f", runThrough.calculatedTotalScore))
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .frame(width: 80, height: 56)
            .background(Color(hex: "1A1A1A"))
            .cornerRadius(16)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 2)
        )
        .shadow(color: .black, radius: 0, x: 6, y: 6)
        .rotationEffect(.degrees(rotation))
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
