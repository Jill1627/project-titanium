import SwiftUI

struct ScoringTrayView: View {
    @Environment(\.theme) var theme
    @Bindable var viewModel: AnalyzerViewModel
    let hapticsService: HapticsService

    @State private var showElementPicker = false

    private let registry = FigureSkatingElementRegistry.shared

    private var selectedElement: FigureSkatingElement? {
        guard viewModel.sportType == .skating else { return nil }
        return registry.element(forCode: viewModel.selectedElementCode)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Element selection button
            if viewModel.sportType == .skating {
                Button {
                    showElementPicker = true
                } label: {
                    HStack {
                        if viewModel.selectedElementCode.isEmpty {
                            Text("Select Element")
                                .foregroundStyle(.secondary)
                        } else {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.selectedElementCode)
                                    .headerMDStyle()
                                    .foregroundStyle(Color.textPrimary)

                                if let element = selectedElement {
                                    Text(element.name)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .sheet(isPresented: $showElementPicker) {
                    ElementPickerSheet(
                        selectedElementCode: $viewModel.selectedElementCode,
                        selectedLevel: $viewModel.selectedLevel
                    )
                }

                // Level picker for elements that require it
                if let element = selectedElement,
                   element.requiresLevel,
                   let levels = element.levels {
                    HStack(spacing: 8) {
                        Text("Level:")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ForEach(["LB", "L1", "L2", "L3", "L4"], id: \.self) { level in
                            if levels[level] != nil {
                                Button {
                                    viewModel.selectedLevel = level
                                } label: {
                                    Text(level)
                                        .font(.caption)
                                        .fontWeight(viewModel.selectedLevel == level ? .bold : .regular)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(viewModel.selectedLevel == level ? Color.purple : Color(.systemGray5))
                                        .foregroundStyle(viewModel.selectedLevel == level ? .white : .primary)
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
            } else {
                // Manual element code for gymnastics
                TextField("Element Code", text: $viewModel.selectedElementCode)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
            }

            if viewModel.sportType == .skating {
                skatingScoring
            } else {
                gymnasticsScoring
            }

            // Coach note
            TextField("Coach note (optional)", text: $viewModel.coachNote)
                .textFieldStyle(.roundedBorder)
                .captionStyle()
        }
        .titaniumCardStyle(hasBloom: true)
    }

    // MARK: - Skating: GOE Slider

    private var skatingScoring: some View {
        VStack(spacing: 8) {
            HStack {
                Text("GOE")
                    .labelCapsStyle()
                    .foregroundStyle(Color.textTertiary)
                Spacer()
                Text(String(format: "%+.1f", viewModel.currentGOE))
                    .headerMDStyle()
                    .monospacedDigit()
                    .foregroundStyle(viewModel.currentGOE >= 0 ? theme.primary : .red.opacity(0.8))
            }

            Slider(value: $viewModel.currentGOE, in: -5...5, step: 0.5)
                .tint(viewModel.currentGOE >= 0 ? theme.primary : .red)
        }
    }

    // MARK: - Gymnastics: Deduction Chips

    private var gymnasticsScoring: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Deductions")
                    .labelCapsStyle()
                    .foregroundStyle(Color.textTertiary)
                Spacer()
                Text(String(format: "-%.1f", viewModel.currentDeductions))
                    .headerMDStyle()
                    .monospacedDigit()
                    .foregroundStyle(.red.opacity(0.8))
            }

            HStack(spacing: 12) {
                ForEach([-0.1, -0.3, -0.5, -1.0], id: \.self) { value in
                    Button {
                        viewModel.addDeduction(abs(value))
                        hapticsService.playDeduction()
                    } label: {
                        Text(String(format: "%.1f", value))
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.15))
                            .foregroundStyle(.red)
                            .clipShape(Capsule())
                    }
                }

                Button {
                    viewModel.currentDeductions = 0
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.caption)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
        }
    }
}
