import PhotosUI
import SwiftData
import SwiftUI

struct RunThroughListView: View {
    let athlete: Athlete
    @Environment(\.modelContext) private var modelContext
    @Query private var allRunThroughs: [RunThrough]
    @State private var selectedItem: PhotosPickerItem?
    @State private var navigateToRun: RunThrough?

    private var runThroughs: [RunThrough] {
        allRunThroughs
            .filter { $0.athleteName == athlete.name }
            .sorted { $0.date > $1.date }
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
        .navigationDestination(for: RunThrough.self) { run in
            AnalyzerView(viewModel: AnalyzerViewModel(runThrough: run))
        }
    }

    private func importVideo(from item: PhotosPickerItem) {
        guard let assetIdentifier = item.itemIdentifier else { return }

        let sport = SportType(rawValue: athlete.sport) ?? .skating
        let run = RunThrough(
            athleteName: athlete.name,
            sport: sport,
            videoLocalIdentifier: assetIdentifier
        )
        modelContext.insert(run)
        selectedItem = nil
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
