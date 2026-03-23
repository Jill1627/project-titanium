import SwiftUI

struct ElementTimelineView: View {
    @Environment(\.theme) var theme
    let elements: [ElementScore]
    let duration: Double
    let onSeek: (Double) -> Void
    let onDelete: (ElementScore) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elements")
                .headerMDStyle()
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
    @Environment(\.theme) var theme
    let element: ElementScore

    var body: some View {
        HStack(spacing: 12) {
            // Timestamp
            Text(formatTimestamp(element.timestamp))
                .captionStyle()
                .monospacedDigit()
                .foregroundStyle(Color.textSecondary)
                .frame(width: 54, alignment: .leading)

            // Element code
            Text(element.elementCode)
                .bodyMDStyle()
                .foregroundStyle(Color.textPrimary)

            // Landing indicator
            Circle()
                .fill(element.landingType.isClean ? theme.primary : .red.opacity(0.8))
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(Color.borderDefault.opacity(0.1), lineWidth: 1))

            Spacer()

            // Execution value
            Text(String(format: "%+.1f", element.executionValue))
                .bodyMDStyle()
                .monospacedDigit()
                .foregroundStyle(element.executionValue >= 0 ? theme.primary : .red.opacity(0.8))

            // Note indicator
            if element.coachNote != nil {
                Image(systemName: "note.text")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14) // radius-md
                .fill(Color.surfaceCardSubtle)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.borderSubtle, lineWidth: 1)
        )
    }

    private func formatTimestamp(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
