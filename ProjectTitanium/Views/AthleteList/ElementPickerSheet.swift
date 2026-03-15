import SwiftUI

struct ElementPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedElementCode: String
    @Binding var selectedLevel: String?

    @State private var searchText = ""
    @State private var selectedCategory: FigureSkatingElement.ElementCategory? = nil

    private let registry = FigureSkatingElementRegistry.shared

    private var filteredElements: [FigureSkatingElement] {
        var elements = registry.allElements

        // Filter by category
        if let category = selectedCategory {
            elements = elements.filter { $0.category == category }
        }

        // Filter by search text
        if !searchText.isEmpty {
            elements = elements.filter {
                $0.code.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        return elements
    }

    private var categories: [FigureSkatingElement.ElementCategory] {
        [.jump, .spin, .stepSequence, .choreographicSequence]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Search elements", text: $searchText)
                        .textFieldStyle(.plain)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                // Category Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryButton(
                            title: "All",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }

                        ForEach(categories, id: \.self) { category in
                            CategoryButton(
                                title: category.displayName,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)

                Divider()

                // Element List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredElements, id: \.code) { element in
                            ElementPickerRow(
                                element: element,
                                isSelected: selectedElementCode == element.code
                            ) {
                                selectElement(element)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Element")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func selectElement(_ element: FigureSkatingElement) {
        selectedElementCode = element.code

        // If element requires level, default to L4
        if element.requiresLevel {
            selectedLevel = "L4"
        } else {
            selectedLevel = nil
        }

        dismiss()
    }
}

struct ElementPickerRow: View {
    let element: FigureSkatingElement
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Element Code
                Text(element.code)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(width: 80, alignment: .leading)

                // Element Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(element.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        // Category badge
                        Text(element.category.displayName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(element.category.color)
                            .cornerRadius(6)

                        // Base value or level indicator
                        if element.requiresLevel {
                            Text("Levels: LB-L4")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        } else if let baseValue = element.baseValue {
                            Text(String(format: "Base: %.1f", baseValue))
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }

                        // Second half bonus indicator
                        if element.secondHalfBonusEligible {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                        }
                    }
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.green)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(isSelected ? Color.green.opacity(0.1) : Color.clear)
        }
        .buttonStyle(.plain)

        Divider()
            .padding(.leading, 116)
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.black : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

extension FigureSkatingElement.ElementCategory {
    var displayName: String {
        switch self {
        case .jump: return "Jumps"
        case .spin: return "Spins"
        case .stepSequence: return "Steps"
        case .choreographicSequence: return "ChSq"
        }
    }

    var color: Color {
        switch self {
        case .jump: return .blue
        case .spin: return .purple
        case .stepSequence: return .orange
        case .choreographicSequence: return .green
        }
    }
}

extension FigureSkatingElement.ElementCategory: Hashable {}
