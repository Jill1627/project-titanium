import SwiftUI

struct ElementScoringSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var element: ElementScore
    let sportType: SportType

    @State private var selectedGOE: Int = 0
    @State private var baseValue: String = ""
    @State private var selectedRotationCall: RotationCall = .clean
    @State private var selectedEdgeCall: EdgeCall = .correct
    @State private var isRepeat: Bool = false
    @State private var isSecondHalf: Bool = false

    private let goeRange = -5...5

    private var calculatedScore: Double {
        guard sportType == .skating else {
            return Double(selectedGOE)
        }

        let base = Double(baseValue) ?? 10.0  // Default to 10.0 if empty
        let engine = SkatingScoring()
        return engine.calculateElementScore(
            baseValue: base,
            goe: Double(selectedGOE),
            rotationCall: selectedRotationCall,
            edgeCall: selectedEdgeCall,
            isRepeat: isRepeat,
            isSecondHalf: isSecondHalf,
            landing: element.landingType
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header Section
            VStack(spacing: 16) {
                HStack(alignment: .bottom) {
                    // Element Code
                    Text(element.elementCode)
                        .font(.system(size: 64, weight: .heavy))
                        .foregroundStyle(.primary)

                    Spacer()

                    // Base Value Input
                    if sportType == .skating {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Base")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)

                            TextField("0.0", text: $baseValue)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.primary)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                        }
                    }

                    // Total Score Badge
                    Text(String(format: "%.2f", calculatedScore))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .background(Color.black)
                        .cornerRadius(12)
                }

                Divider()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))

            // Scrollable Content Section
            ScrollView {
                VStack(spacing: 24) {
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

                            // Background bars
                            GeometryReader { geometry in
                                HStack(spacing: 0) {
                                    ForEach(Array(goeRange), id: \.self) { value in
                                        Rectangle()
                                            .fill(Color.black.opacity(0.05))
                                            .frame(maxWidth: .infinity)
                                            .overlay(
                                                Rectangle()
                                                    .fill(Color.black.opacity(0.1))
                                                    .frame(width: 2)
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                            )
                                    }
                                }
                            }
                            .frame(height: 60)
                            .cornerRadius(12)

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

            // Rotation Calls Row
            if sportType == .skating {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rotation")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        RotationCallButton(
                            label: "<<",
                            call: .downgraded,
                            selectedCall: $selectedRotationCall
                        )

                        RotationCallButton(
                            label: "<",
                            call: .underRotated,
                            selectedCall: $selectedRotationCall
                        )

                        RotationCallButton(
                            label: "q",
                            call: .quarter,
                            selectedCall: $selectedRotationCall
                        )
                    }
                }

                // Edge Calls Row
                VStack(alignment: .leading, spacing: 8) {
                    Text("Edge")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        EdgeCallButton(
                            label: "e",
                            call: .wrongEdge,
                            selectedCall: $selectedEdgeCall
                        )

                        EdgeCallButton(
                            label: "!",
                            call: .attention,
                            selectedCall: $selectedEdgeCall
                        )
                    }
                }

                // Other Flags Row
                HStack(spacing: 12) {
                    ToggleButton(
                        label: "+REP",
                        isSelected: $isRepeat,
                        color: .purple
                    )

                    ToggleButton(
                        label: "2nd Half",
                        isSelected: $isSecondHalf,
                        color: .blue
                    )
                }
            }

            // Landing Row
            HStack(spacing: 12) {
                ToggleButton(
                    label: "FALL",
                    isSelected: Binding(
                        get: { element.landingType == .fall },
                        set: { if $0 { element.landingType = .fall } else { element.landingType = .stuck } }
                    ),
                    color: .red
                )
            }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            // Fixed Save Button
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
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .onAppear {
            selectedGOE = Int(element.executionValue)
            // Default to 10.00 for skating if no base value set yet
            baseValue = element.baseValue > 0 ? String(format: "%.2f", element.baseValue) : (sportType == .skating ? "10.00" : "")
            selectedRotationCall = element.rotationCallType
            selectedEdgeCall = element.edgeCallType
            isRepeat = element.isRepeat
            isSecondHalf = element.isSecondHalf
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

        if sportType == .skating {
            element.baseValue = Double(baseValue) ?? 0.0
            element.rotationCallType = selectedRotationCall
            element.edgeCallType = selectedEdgeCall
            element.isRepeat = isRepeat
            element.isSecondHalf = isSecondHalf
        }

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
                .background(isSelected ? color : Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 2)
                )
                .shadow(color: Color.black, radius: 0, x: 3, y: 3)
        }
    }
}

struct RotationCallButton: View {
    let label: String
    let call: RotationCall
    @Binding var selectedCall: RotationCall

    var body: some View {
        Button {
            selectedCall = selectedCall == call ? .clean : call
        } label: {
            Text(label)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(selectedCall == call ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(selectedCall == call ? Color.orange : Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 2)
                )
                .shadow(color: Color.black, radius: 0, x: 3, y: 3)
        }
    }
}

struct EdgeCallButton: View {
    let label: String
    let call: EdgeCall
    @Binding var selectedCall: EdgeCall

    var body: some View {
        Button {
            selectedCall = selectedCall == call ? .correct : call
        } label: {
            Text(label)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(selectedCall == call ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(selectedCall == call ? Color.orange : Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 2)
                )
                .shadow(color: Color.black, radius: 0, x: 3, y: 3)
        }
    }
}
