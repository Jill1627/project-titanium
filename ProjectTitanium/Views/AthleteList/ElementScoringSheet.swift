import SwiftUI

struct ElementScoringSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var element: ElementScore
    let sportType: SportType

    @State private var selectedGOE: Int = 0
    @State private var isUnderrotated = false
    @State private var hasWrongEdge = false
    @State private var isQuarter = false

    private let goeRange = -5...5

    var body: some View {
        VStack(spacing: 24) {
            // Header Section
            HStack(alignment: .bottom) {
                // Element Code
                Text(element.elementCode)
                    .font(.system(size: 64, weight: .heavy))
                    .foregroundStyle(.primary)

                Spacer()

                // Scores
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Base")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text("1.50")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                }

                // Total Score Badge
                Text(String(format: "%.2f", element.executionValue))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(Color.black)
                    .cornerRadius(12)
            }
            .padding(.bottom, 8)

            Divider()

            // GOE Slider Section
            if sportType == .skating {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Grade of Execution")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)

                    // GOE Track
                    VStack(spacing: 8) {
                        // Value labels
                        HStack(spacing: 0) {
                            ForEach(Array(goeRange), id: \.self) { value in
                                Text(value >= 0 ? "+\(value)" : "\(value)")
                                    .font(.system(size: 12, weight: value == selectedGOE ? .bold : .regular))
                                    .foregroundStyle(value == selectedGOE ? .white : .secondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }

                        // Slider track with current value
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .frame(height: 60)

                            // Current value indicator
                            GeometryReader { geometry in
                                let thumbWidth: CGFloat = 60
                                let trackWidth = geometry.size.width - thumbWidth
                                let normalizedValue = CGFloat(selectedGOE + 5) / CGFloat(goeRange.count - 1)
                                let offset = trackWidth * normalizedValue

                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedGOE >= 0 ? Color.green : Color.red)
                                    .frame(width: thumbWidth, height: 60)
                                    .offset(x: offset)
                            }
                            .frame(height: 60)

                            // Large current value
                            GeometryReader { geometry in
                                let thumbWidth: CGFloat = 60
                                let trackWidth = geometry.size.width - thumbWidth
                                let normalizedValue = CGFloat(selectedGOE + 5) / CGFloat(goeRange.count - 1)
                                let offset = trackWidth * normalizedValue

                                Text(selectedGOE >= 0 ? "+\(selectedGOE)" : "\(selectedGOE)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: thumbWidth, height: 60)
                                    .offset(x: offset)
                            }
                            .frame(height: 60)
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    updateGOE(from: value.location.x, width: UIScreen.main.bounds.width - 48 - 48)
                                }
                        )
                    }
                }
            }

            // Toggle Buttons
            HStack(spacing: 12) {
                ToggleButton(
                    label: "<<",
                    isSelected: $isUnderrotated,
                    color: .orange
                )

                ToggleButton(
                    label: "Q",
                    isSelected: $isQuarter,
                    color: .orange
                )

                ToggleButton(
                    label: "E",
                    isSelected: $hasWrongEdge,
                    color: .orange
                )

                ToggleButton(
                    label: "F",
                    isSelected: Binding(
                        get: { element.landingType == .fall },
                        set: { if $0 { element.landingType = .fall } else { element.landingType = .stuck } }
                    ),
                    color: .red
                )
            }

            Spacer()

            // Save Button
            Button {
                saveAndDismiss()
            } label: {
                Text("Save")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .cornerRadius(16)
            }
        }
        .padding(24)
        .onAppear {
            selectedGOE = Int(element.executionValue)
        }
    }

    private func updateGOE(from x: CGFloat, width: CGFloat) {
        let thumbWidth: CGFloat = 60
        let trackWidth = width - thumbWidth
        let normalizedX = max(0, min(trackWidth, x - thumbWidth / 2))
        let percentage = normalizedX / trackWidth
        let rawValue = percentage * CGFloat(goeRange.count - 1)
        selectedGOE = Int(round(rawValue)) + goeRange.lowerBound
    }

    private func saveAndDismiss() {
        element.executionValue = Double(selectedGOE)
        dismiss()
    }
}

struct ToggleButton: View {
    let label: String
    @Binding var isSelected: Bool
    let color: Color

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            Text(label)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isSelected ? color : Color(.systemGray6))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 2)
                )
                .shadow(color: Color.black, radius: 0, x: 3, y: 3)
        }
    }
}
