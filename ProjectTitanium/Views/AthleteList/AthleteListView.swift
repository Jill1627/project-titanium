import SwiftUI
import SwiftData

struct AthleteListView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedSport") private var selectedSport = SportType.skating.rawValue
    @Query(sort: \Athlete.name) private var athletes: [Athlete]
    @State private var showingAddAthlete = false
    @State private var newAthleteName = ""

    private var currentSport: SportType {
        SportType(rawValue: selectedSport) ?? .skating
    }

    private var filteredAthletes: [Athlete] {
        athletes.filter { $0.sport == selectedSport }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredAthletes.isEmpty {
                    ContentUnavailableView(
                        "No Athletes",
                        systemImage: "person.3",
                        description: Text("Add your first athlete to get started.")
                    )
                } else {
                    List {
                        ForEach(filteredAthletes) { athlete in
                            NavigationLink(value: athlete) {
                                AthleteRow(athlete: athlete)
                            }
                        }
                        .onDelete(perform: deleteAthletes)
                    }
                }
            }
            .navigationTitle("Athletes")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        ForEach(SportType.allCases) { sport in
                            Button {
                                selectedSport = sport.rawValue
                            } label: {
                                Label(sport.displayName, systemImage: sport.iconName)
                            }
                        }
                    } label: {
                        Label(currentSport.displayName, systemImage: currentSport.iconName)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddAthlete = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Athlete.self) { athlete in
                RunThroughListView(athlete: athlete)
            }
            .navigationDestination(for: DashboardDestination.self) { dest in
                DashboardView(athlete: dest.athlete)
            }
            .alert("Add Athlete", isPresented: $showingAddAthlete) {
                TextField("Name", text: $newAthleteName)
                Button("Cancel", role: .cancel) {
                    newAthleteName = ""
                }
                Button("Add") {
                    addAthlete()
                }
            }
        }
    }

    private func addAthlete() {
        guard !newAthleteName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let athlete = Athlete(name: newAthleteName.trimmingCharacters(in: .whitespaces), sport: currentSport)
        modelContext.insert(athlete)
        newAthleteName = ""
    }

    private func deleteAthletes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredAthletes[index])
        }
    }
}

struct AthleteRow: View {
    let athlete: Athlete

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading) {
                Text(athlete.name)
                    .font(.body)
            }

            Spacer()

            NavigationLink(value: DashboardDestination(athlete: athlete)) {
                Image(systemName: "chart.bar")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
        }
    }
}

struct DashboardDestination: Hashable {
    let athlete: Athlete
}

#Preview {
    AthleteListView()
        .modelContainer(for: Athlete.self, inMemory: true)
}
