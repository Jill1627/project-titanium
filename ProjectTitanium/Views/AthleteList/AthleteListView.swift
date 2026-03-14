import SwiftUI
import SwiftData

struct AthleteListView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedSport") private var selectedSport = SportType.skating.rawValue
    @Query(sort: \Athlete.name) private var athletes: [Athlete]
    @Query private var allRunThroughs: [RunThrough]
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
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredAthletes) { athlete in
                                NavigationLink(value: athlete) {
                                    AthleteCard(athlete: athlete, runThroughs: runThroughs(for: athlete))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
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

    private func runThroughs(for athlete: Athlete) -> [RunThrough] {
        allRunThroughs.filter { $0.athleteID == athlete.id }
    }

    private func addAthlete() {
        guard !newAthleteName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let athlete = Athlete(name: newAthleteName.trimmingCharacters(in: .whitespaces), sport: currentSport)
        modelContext.insert(athlete)
        newAthleteName = ""
    }
}

struct AthleteCard: View {
    let athlete: Athlete
    let runThroughs: [RunThrough]

    private var highestScore: Double {
        runThroughs.map(\.calculatedTotalScore).max() ?? 0
    }

    private var latestScore: Double {
        runThroughs.sorted { $0.date > $1.date }.first?.calculatedTotalScore ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top row: Avatar, Name, Highest Score
            HStack(alignment: .center, spacing: 12) {
                // Avatar
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 2)
                    )

                // Name
                Text(athlete.name)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(.black)
                    .lineLimit(1)

                Spacer()

                // Highest Score
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Highest")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Text(String(format: "%.0f", highestScore))
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(.black)
                }
            }
            .padding(16)
            .background(Color.white)

            // Bottom row: Latest Score
            HStack {
                Text("LATEST")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(1)

                Spacer()

                Text(String(format: "%.0f", latestScore))
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "1A1A1A"))
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 2)
        )
        .shadow(color: .black, radius: 0, x: 6, y: 6)
    }
}

struct DashboardDestination: Hashable {
    let athlete: Athlete
}

#Preview {
    AthleteListView()
        .modelContainer(for: Athlete.self, inMemory: true)
}
