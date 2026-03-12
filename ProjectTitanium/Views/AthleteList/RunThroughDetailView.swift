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
    @Bindable var runThrough: RunThrough
    @State private var showingAddElement = false
    @State private var showingEditNote = false
    @State private var selectedElement: ElementScore?

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(runThrough.programName)
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(.primary)

                    Text("Runthrough - \(runThrough.date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
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
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            // Score
                            Text(String(format: "%.2f", runThrough.totalScore))
                                .font(.system(size: 44, weight: .heavy))
                                .foregroundStyle(.white)

                            // Play button
                            Circle()
                                .fill(.white)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.black)
                                        .offset(x: 2)
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
                        .stroke(Color.black, lineWidth: 2)
                )
                .shadow(color: Color.black, radius: 0, x: 4, y: 4)

                Divider()

                // Elements Header
                HStack {
                    Text("Elements")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(runThrough.elements.count) elements")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                // Elements List
                LazyVStack(spacing: 12) {
                    ForEach(runThrough.elements) { element in
                        ElementRowView(element: element)
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
                    showingAddElement = true
                } label: {
                    Text("+ Add Element")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    Color.black,
                                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                                )
                        )
                        .shadow(color: Color.black, radius: 0, x: 4, y: 4)
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
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                    }
                    .foregroundStyle(.primary)
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
                        .foregroundStyle(.primary)
                }
            }
        }
        .sheet(isPresented: $showingAddElement) {
            AddElementSheet(runThrough: runThrough)
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

    private func deleteElement(_ element: ElementScore) {
        withAnimation {
            if let index = runThrough.elements.firstIndex(where: { $0.id == element.id }) {
                runThrough.elements.remove(at: index)
                // Recalculate total score
                // TODO: Use ScoringEngine to recalculate
            }
        }
    }
}

// MARK: - Element Row View

struct ElementRowView: View {
    let element: ElementScore

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
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)

                Text(formatTime(element.timestamp))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Score
            Text(String(format: "%.2f", element.executionValue))
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 2)
        )
        .shadow(color: Color.black, radius: 0, x: 4, y: 4)
    }

    private var statusColor: Color {
        switch element.landingType {
        case .stuck:
            return .green
        case .hop, .step:
            return .orange
        case .fall:
            return .red
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

// MARK: - Add Element Sheet

struct AddElementSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var runThrough: RunThrough
    @State private var elementCode = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Element Details") {
                    TextField("Element Code", text: $elementCode)
                        .textInputAutocapitalization(.characters)
                }
            }
            .navigationTitle("Add Element")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addElement()
                    }
                    .disabled(elementCode.isEmpty)
                }
            }
        }
    }

    private func addElement() {
        let newElement = ElementScore(
            elementCode: elementCode,
            timestamp: 0,
            executionValue: 0,
            landing: LandingType.stuck
        )
        runThrough.elements.append(newElement)
        dismiss()
    }
}

// MARK: - Edit Note Sheet

struct EditNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
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
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        runThrough.coachNote = noteText.isEmpty ? nil : noteText
                        dismiss()
                    }
                }
            }
        }
    }
}
