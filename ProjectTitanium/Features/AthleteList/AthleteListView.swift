import SwiftUI
import SwiftData

struct AthleteListView: View {
    @Environment(\.theme) var theme
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Athlete.name) private var athletes: [Athlete]
    @Query private var allRunThroughs: [RunThrough]
    @AppStorage("selectedSport") private var selectedSport = SportType.skating.rawValue
    @State private var showingAddAthlete = false
    @State private var newAthleteName = ""

    private var filteredAthletes: [Athlete] {
        athletes.filter { $0.sport == selectedSport }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Inline Screen Header
                    HStack(alignment: .center, spacing: 8) {
                        Menu {
                            ForEach(SportType.allCases) { sport in
                                Button {
                                    selectedSport = sport.rawValue
                                } label: {
                                    HStack {
                                        Text(sport.displayName)
                                        if theme.activeTheme == sport {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text("Athletes")
                                    .headerXLStyle()
                                    .foregroundStyle(Color.textPrimary)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(theme.primary)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            showingAddAthlete = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(theme.primary)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 24)

                    if filteredAthletes.isEmpty {
                        let activeSport: SportType = SportType(rawValue: selectedSport) ?? .skating
                        let otherSport: SportType = activeSport == .skating ? .gymnastics : .skating
                        let hasAthletesInOtherSport = !athletes.filter { $0.sport == otherSport.rawValue }.isEmpty
                        
                        ContentUnavailableView {
                            Label("No \(activeSport.displayName) Athletes", systemImage: activeSport.iconName)
                        } description: {
                            Text(hasAthletesInOtherSport 
                                 ? "You have athletes in \(otherSport.displayName). Switch views to see them."
                                 : "Add your first athlete to get started.")
                        } actions: {
                            if hasAthletesInOtherSport {
                                Button("Switch to \(otherSport.displayName)") {
                                    selectedSport = otherSport.rawValue
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(theme.primary)
                            } else {
                                Button("Add Athlete") {
                                    showingAddAthlete = true
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(theme.primary)
                            }
                        }
                        .padding(.top, 100)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(filteredAthletes) { athlete in
                                NavigationLink(value: athlete) {
                                    AthleteCard(athlete: athlete, runThroughs: runThroughs(for: athlete))
                                }
                                .buttonStyle(.plain)

                                 
                            }
                        }
                        .padding(.horizontal, 16)
                        SparkleIllustration(size: 28, fillColor: .orange, outlineColor: Color.borderDefault)
                .offset(y: -2)
                    }
                }
            }
            .background(Color.surfacePage)
            .navigationBarHidden(true)
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
        let currentSport = SportType(rawValue: selectedSport) ?? .skating
        let athlete = Athlete(name: newAthleteName.trimmingCharacters(in: .whitespaces), sport: currentSport)
        modelContext.insert(athlete)
        newAthleteName = ""
    }
}

struct AthleteCard: View {
    @Environment(\.theme) var theme
    let athlete: Athlete
    let runThroughs: [RunThrough]

    private var highestScore: Double {
        runThroughs.map(\.calculatedTotalScore).max() ?? 0
    }

    private var latestScore: Double {
        runThroughs.sorted { $0.date > $1.date }.first?.calculatedTotalScore ?? 0
    }

    private var latestDate: Date? {
        runThroughs.sorted { $0.date > $1.date }.first?.date
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // TOP ROW: Avatar + Name
            HStack(alignment: .center, spacing: 16) {
                // Left: Avatar
                ZStack {
                    Circle()
                        .fill(theme.primary)
                        .frame(width: 52, height: 52)
                    
                    Text(String(athlete.name.prefix(1)).uppercased())
                        .font(.headerSM)
                        .foregroundStyle(.white)
                }
                .overlay(
                    Circle()
                        .strokeBorder(Color.borderDefault, lineWidth: 1.5)
                )

                // Name (Full width)
                Text(athlete.name)
                    .headerMDStyle() // Larger header for name
                    .foregroundStyle(Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true) // No truncation!
                
                Spacer()
                
                // Motif decoration
                SparkleIllustration(size: 24, fillColor: .orange, outlineColor: Color.borderDefault)
                    .opacity(0.8)
                    .padding(.trailing, 4)
            }

            // BOTTOM ROW: Scoring Analytics (Dual-Metric)
            HStack(spacing: 40) {
                scoreColumn(label: "Highest", value: highestScore)
                scoreColumn(label: "Latest", value: latestScore)
            }
            .layoutPriority(1)
        }
        .titaniumCardStyle(hasBloom: true)
    }

    private func scoreColumn(label: String, value: Double) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(label)
                .captionStyle()
                .foregroundStyle(Color.textSecondary)

            Text(String(format: "%.1f", value))
                .scoreMediumStyle()
                .foregroundStyle(theme.primary)
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
