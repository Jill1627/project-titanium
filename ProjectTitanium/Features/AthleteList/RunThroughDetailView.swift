import SwiftUI
import SwiftData

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct RunThroughDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) var theme
    @Bindable var runThrough: RunThrough
    @State private var showingAddElement = false
    @State private var showingEditNote = false
    @State private var showingPlayer = false
    @State private var selectedElement: ElementScore?
    @State private var newElement: ElementScore?

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text(runThrough.programName)
                        .headerXLStyle()
                        .foregroundStyle(Color.textPrimary)

                    Text("Runthrough - \(runThrough.date.formatted(date: .abbreviated, time: .omitted))")
                        .labelCapsStyle()
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Video Thumbnail Section
                ZStack(alignment: .bottom) {
                    // Background image placeholder (black for now, will show video thumbnail)
                    Rectangle()
                        .fill(Color.black)
                        .aspectRatio(16/9, contentMode: .fill)
                        .clipped()

                    // Gradient overlay at bottom
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.7),
                            Color.clear,
                            Color.black.opacity(0.1)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 120)

                    // Score and note overlay
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .bottom, spacing: 20) {
                            // Score
                            VStack(alignment: .leading, spacing: -8) {
                                Text(String(format: "%.2f", runThrough.calculatedTotalScore))
                                    .font(.custom("Sharpie-Bold", size: 56))
                                    .foregroundStyle(.white)
                                
                                Text("TOTAL SCORE")
                                    .labelCapsStyle(isWider: true)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.8))
                            }

                            Spacer()

                            // Play button
                            Button {
                                showingPlayer = true
                            } label: {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.white)
                                    .frame(width: 72, height: 72)
                                    .background(theme.primary)
                                    .cornerRadius(36)
                                    .shadow(color: theme.shadow.opacity(0.35), radius: 0, x: 4, y: 4)
                            }
                        }

                        // Coach note
                        if let note = runThrough.coachNote, !note.isEmpty {
                            Text(note)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                        }
                    }
                    .padding([.horizontal, .bottom], 16)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .aspectRatio(16/9, contentMode: .fit)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.borderDefault, lineWidth: 1.5)
                )
                .shadow(color: Color.borderDefault.opacity(0.2), radius: 0, x: 4, y: 4)

                Divider()

                // Elements Header
                HStack {
                    Text("Elements")
                        .headerMDStyle()
                        .foregroundStyle(Color.textPrimary)

                    Spacer()

                    Text("\(runThrough.elements.count) elements")
                        .bodyMDStyle()
                        .foregroundStyle(Color.textTertiary)
                }

                // Elements List
                LazyVStack(spacing: 12) {
                    ForEach(runThrough.elements) { element in
                        ElementRowView(element: element, sportType: runThrough.sportType)
                            .onTapGesture {
                                selectedElement = element
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteElement(element)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }

                // Add Element Button
                Button {
                    createAndShowNewElement()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .black))
                        Text("Add Element")
                            .headerSMStyle()
                    }
                    .foregroundStyle(theme.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(theme.primary.opacity(0.08))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                theme.primary.opacity(0.2),
                                lineWidth: 1.5
                            )
                    )
                }
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(theme.primary)
                        
                        Text("Back")
                            .headerSMStyle()
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEditNote = true
                    } label: {
                        Label("Edit Note", systemImage: "note.text")
                    }

                    Button {
                        // Edit program name
                    } label: {
                        Label("Edit Program Name", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .sheet(item: $newElement) { element in
            ElementScoringSheet(
                element: element,
                sportType: runThrough.sportType
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingEditNote) {
            EditNoteSheet(runThrough: runThrough)
        }
        .sheet(item: $selectedElement) { element in
            ElementScoringSheet(
                element: element,
                sportType: runThrough.sportType
            )
            .presentationDetents([.medium, .large])
        }
    }

    private func createAndShowNewElement() {
        // Create a new blank element and add to runthrough
        let element = ElementScore(
            elementCode: "",
            timestamp: 0,
            executionValue: 0,
            landing: .stuck
        )
        runThrough.elements.append(element)
        // Store reference and show sheet
        newElement = element
    }

    private func deleteElement(_ element: ElementScore) {
        withAnimation {
            if let index = runThrough.elements.firstIndex(where: { $0.id == element.id }) {
                runThrough.elements.remove(at: index)
            }
        }
    }
}

// MARK: - Element Row View

struct ElementRowView: View {
    @Environment(\.theme) var theme
    let element: ElementScore
    let sportType: SportType

    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            Circle()
                .fill(statusColor)
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: statusIcon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

            // Element Info
            VStack(alignment: .leading, spacing: 2) {
                Text(element.elementCode)
                    .headerSMStyle()
                    .foregroundStyle(Color.textPrimary)

                Text(formatTime(element.timestamp))
                    .captionStyle()
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            // Score
            Text(String(format: "%.2f", element.calculatedScore(sport: sportType)))
                .headerLGStyle()
                .foregroundStyle(Color.textPrimary)
        }
        .padding(16)
        .background(Color.surfaceCardSubtle)
        .cornerRadius(14) // radius-md
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.borderSubtle, lineWidth: 1)
        )
    }

    private var statusColor: Color {
        switch element.landingType {
        case .stuck:
            return theme.primary
        case .hop, .step:
            return .orange.opacity(0.8)
        case .fall:
            return .red.opacity(0.8)
        }
    }

    private var statusIcon: String {
        switch element.landingType {
        case .stuck:
            return "checkmark"
        case .hop, .step:
            return "exclamationmark"
        case .fall:
            return "xmark"
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Edit Note Sheet

struct EditNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) var theme
    @Bindable var runThrough: RunThrough
    @State private var noteText: String

    init(runThrough: RunThrough) {
        self.runThrough = runThrough
        _noteText = State(initialValue: runThrough.coachNote ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Coach Notes") {
                    TextEditor(text: $noteText)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("Edit Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .headerSMStyle()
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        runThrough.coachNote = noteText.isEmpty ? nil : noteText
                        dismiss()
                    } label: {
                        Text("Save")
                            .headerSMStyle()
                            .foregroundStyle(theme.primary)
                    }
                }
            }
        }
    }
}
