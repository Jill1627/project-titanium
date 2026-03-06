import SwiftUI
import SwiftData

struct RunThroughListView: View {
    let athlete: Athlete
    @Environment(\.modelContext) private var modelContext
    @Query private var allRunThroughs: [RunThrough]

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
                    RunThroughRow(runThrough: run)
                }
            }
        }
        .navigationTitle(athlete.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // TODO: Photo picker for video import
                } label: {
                    Image(systemName: "plus")
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
