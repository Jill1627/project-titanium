import SwiftUI

struct ElementScoringSheet: View {
    @Environment(\.theme) var theme
    @Environment(\.dismiss) private var dismiss
    @Bindable var element: ElementScore
    let sportType: SportType

    @State private var selectedGOE: Int = 0
    @State private var selectedElementCode: String = ""
    @State private var selectedLevel: String? = nil
    @State private var selectedRotationCall: RotationCall = .clean
    @State private var selectedEdgeCall: EdgeCall = .correct
    @State private var isRepeat: Bool = false
    @State private var isSecondHalf: Bool = false
    @State private var showElementPicker = false

    private let goeRange = -5...5
    private let registry = FigureSkatingElementRegistry.shared

    private var selectedElement: FigureSkatingElement? {
        registry.element(forCode: selectedElementCode)
    }

    private var resolvedBaseValue: Double {
        guard let element = selectedElement else { return 0.0 }

        if element.requiresLevel {
            guard let level = selectedLevel,
                  let levelValue = element.levels?[level] else {
                return 0.0
            }
            return levelValue
        }

        return element.baseValue ?? 0.0
    }

    private var calculatedScore: Double {
        guard sportType == .skating else {
            return Double(selectedGOE)
        }

        let engine = SkatingScoring()
        let result = engine.calculateElementScore(
            elementCode: selectedElementCode,
            level: selectedLevel,
            goe: selectedGOE,
            rotationCall: selectedRotationCall,
            edgeCall: selectedEdgeCall,
            isRepeat: isRepeat,
            isSecondHalf: isSecondHalf,
            landing: element.landingType
        )

        return result.score
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            headerSection
            
            ScrollView {
                controlsSection
            }
            
            saveButtonSection
        }
        .sheet(isPresented: $showElementPicker) {
            ElementPickerSheet(
                selectedElementCode: $selectedElementCode,
                selectedLevel: $selectedLevel
            )
        }
        .onAppear {
            selectedGOE = Int(element.executionValue)
            selectedElementCode = element.elementCode
            selectedLevel = element.level
            selectedRotationCall = element.rotationCallType
            selectedEdgeCall = element.edgeCallType
            isRepeat = element.isRepeat
            isSecondHalf = element.isSecondHalf
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    // Element Code
                    elementCodeDisplay
                }

                Spacer()

                // Base Value Display
                if sportType == .skating && !selectedElementCode.isEmpty {
                    baseValueDisplay
                }

                // Total Score Badge
                totalScoreBadge
            }

            Divider()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private var elementCodeDisplay: some View {
        if selectedElementCode.isEmpty {
            Button {
                showElementPicker = true
            } label: {
                Text("Select Element")
                    .headerXLStyle()
                    .foregroundStyle(theme.primary)
            }
        } else {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 12) {
                    Text(selectedElementCode)
                        .font(.custom("Sharpie-Extrabold", size: 48))
                        .foregroundStyle(Color.textPrimary)

                    Button {
                        showElementPicker = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(theme.primary)
                    }
                }

                if let element = selectedElement {
                    Text(element.name)
                        .font(.custom("DM Sans", size: 14).weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var baseValueDisplay: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("Base")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(String(format: "%.2f", resolvedBaseValue))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)
        }
    }
    
    @ViewBuilder
    private var totalScoreBadge: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.2f", calculatedScore))
                .scoreMediumStyle()
                .foregroundStyle(theme.primary)
            
            Text("PTS")
                .labelCapsStyle(isWider: true)
                .font(.system(size: 9))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(theme.primary.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(theme.primary.opacity(0.15), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var controlsSection: some View {
        VStack(spacing: 24) {
            // Level Picker
            if sportType == .skating,
               let element = selectedElement,
               element.requiresLevel,
               let levels = element.levels {
                levelPickerSection(levels: levels)
            }

            // GOE Slider Section
            if sportType == .skating && !selectedElementCode.isEmpty {
                goeSliderSection
            }

            // Rotation/Edge/Flags
            if sportType == .skating {
                rotationAndEdgeSection
            }

            // Landing Row
            landingSection
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
    
    @ViewBuilder
    private func levelPickerSection(levels: [String: Double]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LEVEL")
                .labelCapsStyle()
                .foregroundStyle(Color.textTertiary)

            HStack(spacing: 12) {
                ForEach(["LB", "L1", "L2", "L3", "L4"], id: \.self) { level in
                    if levels[level] != nil {
                        LevelButton(
                            level: level,
                            selectedLevel: $selectedLevel,
                            theme: theme
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(Color.surfaceCardSubtle)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borderSubtle, lineWidth: 1))
    }
    
    @ViewBuilder
    private var goeSliderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GRADE OF EXECUTION")
                .labelCapsStyle()
                .foregroundStyle(Color.textTertiary)

            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    ForEach(Array(goeRange), id: \.self) { value in
                        Text(value >= 0 ? "+\(value)" : "\(value)")
                            .captionStyle()
                            .foregroundStyle(value == selectedGOE ? Color.textPrimary : Color.textTertiary)
                            .frame(maxWidth: .infinity)
                    }
                }

                goeSliderTrack
            }
        }
        .padding(16)
        .background(Color.surfaceCardSubtle)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borderSubtle, lineWidth: 1))
    }
    
    @ViewBuilder
    private var goeSliderTrack: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.surfaceInput)
                .frame(height: 52)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borderSubtle, lineWidth: 1))

            GeometryReader { geometry in
                let thumbWidth: CGFloat = 52
                let trackWidth = geometry.size.width - thumbWidth
                let normalizedValue = CGFloat(selectedGOE + 5) / CGFloat(goeRange.count - 1)
                let offset = trackWidth * normalizedValue

                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedGOE >= 0 ? theme.primary : .red.opacity(0.8))
                    .frame(width: thumbWidth, height: 44)
                    .padding(4)
                    .offset(x: offset)
            }
            .frame(height: 52)

            GeometryReader { geometry in
                let thumbWidth: CGFloat = 52
                let trackWidth = geometry.size.width - thumbWidth
                let normalizedValue = CGFloat(selectedGOE + 5) / CGFloat(goeRange.count - 1)
                let offset = trackWidth * normalizedValue

                Text(selectedGOE >= 0 ? "+\(selectedGOE)" : "\(selectedGOE)")
                    .headerSMStyle()
                    .foregroundStyle(.white)
                    .frame(width: thumbWidth, height: 52)
                    .offset(x: offset)
            }
            .frame(height: 52)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    updateGOE(from: value.location.x, width: UIScreen.main.bounds.width - 48 - 48)
                }
        )
    }
    
    @ViewBuilder
    private var rotationAndEdgeSection: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("ROTATION")
                    .labelCapsStyle()
                    .foregroundStyle(Color.textTertiary)

                HStack(spacing: 12) {
                    RotationCallButton(label: "<<", call: .downgraded, selectedCall: $selectedRotationCall, theme: theme)
                    RotationCallButton(label: "<", call: .underRotated, selectedCall: $selectedRotationCall, theme: theme)
                    RotationCallButton(label: "q", call: .quarter, selectedCall: $selectedRotationCall, theme: theme)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("EDGE")
                    .labelCapsStyle()
                    .foregroundStyle(Color.textTertiary)

                HStack(spacing: 12) {
                    EdgeCallButton(label: "e", call: .wrongEdge, selectedCall: $selectedEdgeCall, theme: theme)
                    EdgeCallButton(label: "!", call: .attention, selectedCall: $selectedEdgeCall, theme: theme)
                }
            }

            HStack(spacing: 12) {
                ToggleButton(label: "+REP", isSelected: $isRepeat, color: theme.primary, theme: theme)
                ToggleButton(label: "2nd Half", isSelected: $isSecondHalf, color: theme.primary, theme: theme)
            }
        }
        .padding(16)
        .background(Color.surfaceCardSubtle)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borderSubtle, lineWidth: 1))
    }
    
    @ViewBuilder
    private var landingSection: some View {
        HStack(spacing: 12) {
            ToggleButton(
                label: "FALL",
                isSelected: Binding(
                    get: { element.landingType == .fall },
                    set: { if $0 { element.landingType = .fall } else { element.landingType = .stuck } }
                ),
                color: .red.opacity(0.8),
                theme: theme
            )
        }
        .padding(16)
        .background(Color.surfaceCardSubtle)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borderSubtle, lineWidth: 1))
    }
    
    @ViewBuilder
    private var saveButtonSection: some View {
        Button {
            saveAndDismiss()
        } label: {
            Text("Save")
                .headerSMStyle()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(theme.primary)
                .cornerRadius(16)
                .shadow(color: theme.shadow.opacity(0.35), radius: 0, x: 4, y: 4)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
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
        element.elementCode = selectedElementCode

        if sportType == .skating {
            element.baseValue = resolvedBaseValue  // Store resolved value for reference
            element.level = selectedLevel
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
    let theme: ThemeManager

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            Text(label)
                .headerSMStyle()
                .foregroundStyle(isSelected ? .white : Color.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isSelected ? color : Color.surfaceInput)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(isSelected ? Color.clear : Color.borderSubtle, lineWidth: 1)
                )
        }
    }
}

struct RotationCallButton: View {
    let label: String
    let call: RotationCall
    @Binding var selectedCall: RotationCall
    let theme: ThemeManager

    var body: some View {
        Button {
            selectedCall = selectedCall == call ? .clean : call
        } label: {
            Text(label)
                .headerSMStyle()
                .foregroundStyle(selectedCall == call ? .white : Color.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(selectedCall == call ? .orange.opacity(0.8) : Color.surfaceInput)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(selectedCall == call ? Color.clear : Color.borderSubtle, lineWidth: 1)
                )
        }
    }
}

struct EdgeCallButton: View {
    let label: String
    let call: EdgeCall
    @Binding var selectedCall: EdgeCall
    let theme: ThemeManager

    var body: some View {
        Button {
            selectedCall = selectedCall == call ? .correct : call
        } label: {
            Text(label)
                .headerSMStyle()
                .foregroundStyle(selectedCall == call ? .white : Color.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(selectedCall == call ? .orange.opacity(0.8) : Color.surfaceInput)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(selectedCall == call ? Color.clear : Color.borderSubtle, lineWidth: 1)
                )
        }
    }
}

struct LevelButton: View {
    let level: String
    @Binding var selectedLevel: String?
    let theme: ThemeManager

    var body: some View {
        Button {
            selectedLevel = level
        } label: {
            Text(level)
                .headerSMStyle()
                .foregroundStyle(selectedLevel == level ? .white : Color.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(selectedLevel == level ? theme.primary : Color.surfaceInput)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(selectedLevel == level ? Color.clear : Color.borderSubtle, lineWidth: 1)
                )
        }
    }
}
