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
                List(runThroughs) { run in
                    NavigationLink(value: run) {
                        RunThroughRow(runThrough: run)
                    }
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

struct RunThroughRow: View {
    let runThrough: RunThrough

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(runThrough.date, style: .date)
                .font(.headline)
            HStack {
                Text("\(runThrough.elements.count) elements")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.2f", runThrough.totalScore))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.vertical, 4)
    }
}
