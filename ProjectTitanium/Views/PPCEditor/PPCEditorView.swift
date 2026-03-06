import SwiftData
import SwiftUI

struct PPCEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedSport") private var selectedSport = SportType.skating.rawValue

    @Query(sort: \PlannedProgramContent.createdAt, order: .descending)
    private var allPPCs: [PlannedProgramContent]

    @State private var showingNewPPC = false
    @State private var newPPCName = ""

    private var currentSport: SportType {
        SportType(rawValue: selectedSport) ?? .skating
    }

    private var filteredPPCs: [PlannedProgramContent] {
        allPPCs.filter { $0.sport == selectedSport }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredPPCs.isEmpty {
                    ContentUnavailableView(
                        "No Programs",
                        systemImage: "list.clipboard",
                        description: Text("Create a planned program content list for one-tap review.")
                    )
                } else {
                    List {
                        ForEach(filteredPPCs) { ppc in
                            NavigationLink {
                                PPCDetailView(ppc: ppc)
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
                        .onDelete { offsets in
                            for index in offsets {
                                modelContext.delete(filteredPPCs[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Programs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewPPC = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("New Program", isPresented: $showingNewPPC) {
                TextField("Program Name", text: $newPPCName)
                Button("Cancel", role: .cancel) { newPPCName = "" }
                Button("Create") {
                    let ppc = PlannedProgramContent(name: newPPCName, sport: currentSport)
                    modelContext.insert(ppc)
                    newPPCName = ""
                }
            }
        }
    }
}

struct PPCDetailView: View {
    @Bindable var ppc: PlannedProgramContent
    @State private var newElement = ""

    var body: some View {
        List {
            Section("Elements") {
                ForEach(Array(ppc.elementCodes.enumerated()), id: \.offset) { index, code in
                    HStack {
                        Text("\(index + 1).")
                            .foregroundStyle(.secondary)
                            .frame(width: 30)
                        Text(code)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                }
                .onDelete { offsets in
                    ppc.elementCodes.remove(atOffsets: offsets)
                }
                .onMove { from, to in
                    ppc.elementCodes.move(fromOffsets: from, toOffset: to)
                }
            }

            Section {
                HStack {
                    TextField("Element Code (e.g., 3A)", text: $newElement)
                    Button {
                        guard !newElement.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        ppc.elementCodes.append(newElement.trimmingCharacters(in: .whitespaces))
                        newElement = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
        .navigationTitle(ppc.name)
        .toolbar {
            EditButton()
        }
    }
}
