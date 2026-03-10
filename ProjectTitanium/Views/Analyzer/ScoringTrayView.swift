import SwiftUI

struct ScoringTrayView: View {
    @Bindable var viewModel: AnalyzerViewModel
    let hapticsService: HapticsService

    var body: some View {
        VStack(spacing: 12) {
            // Element code input
            TextField("Element Code (e.g., 3A, 2Lz)", text: $viewModel.selectedElementCode)
                .textFieldStyle(.roundedBorder)
                .font(.headline)

            if viewModel.sportType == .skating {
                skatingScoring
            } else {
                gymnasticsScoring
            }

            // Coach note
            TextField("Coach note (optional)", text: $viewModel.coachNote)
                .textFieldStyle(.roundedBorder)
                .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Skating: GOE Slider

    private var skatingScoring: some View {
        VStack(spacing: 8) {
            HStack {
                Text("GOE")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "%+.1f", viewModel.currentGOE))
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundStyle(viewModel.currentGOE >= 0 ? Color.accentMint : Color.accentCoral)
            }

            Slider(value: $viewModel.currentGOE, in: -5...5, step: 0.5)
                .tint(viewModel.currentGOE >= 0 ? Color.accentColor : .red)
        }
    }

    // MARK: - Gymnastics: Deduction Chips

    private var gymnasticsScoring: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Deductions")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "-%.1f", viewModel.currentDeductions))
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundStyle(.red)
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
