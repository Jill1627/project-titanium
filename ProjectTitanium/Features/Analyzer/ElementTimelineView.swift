import SwiftUI

struct ElementTimelineView: View {
    let elements: [ElementScore]
    let duration: Double
    let onSeek: (Double) -> Void
    let onDelete: (ElementScore) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Elements")
                .font(.headline)
                .padding(.horizontal)

            if elements.isEmpty {
                Text("No elements scored yet. Tap Sync to add one.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(elements) { element in
                            ElementRow(element: element)
                                .onTapGesture {
                                    onSeek(element.timestamp)
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        onDelete(element)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct ElementRow: View {
    let element: ElementScore

    var body: some View {
        HStack(spacing: 12) {
            // Timestamp
            Text(formatTimestamp(element.timestamp))
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)

            // Element code
            Text(element.elementCode)
                .font(.subheadline)
                .fontWeight(.semibold)

            // Landing indicator
            Circle()
                .fill(element.landingType.isClean ? Color.accentColor : .red)
                .frame(width: 8, height: 8)

            Spacer()

            // Execution value
            Text(String(format: "%+.1f", element.executionValue))
                .font(.subheadline)
                .fontWeight(.medium)
                .monospacedDigit()
                .foregroundStyle(element.executionValue >= 0 ? Color.accentColor : .red)

            // Note indicator
            if element.coachNote != nil {
                Image(systemName: "note.text")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }

    private func formatTimestamp(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
