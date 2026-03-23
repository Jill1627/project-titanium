import Foundation
import SwiftData

struct SeedDataService {
    static func seedMockData(modelContext: ModelContext) {
        // Check if data already exists
        let descriptor = FetchDescriptor<Athlete>()
        let existingAthletes = try? modelContext.fetch(descriptor)

        if let athletes = existingAthletes, !athletes.isEmpty {
            print("✅ Mock data already exists, skipping seed")
            return
        }

        print("🌱 Seeding mock data...")

        // Create Figure Skating Athletes
        let skater1 = Athlete(name: "Emma Chen", sport: .skating)
        let skater2 = Athlete(name: "Sophie Martinez", sport: .skating)

        // Create Gymnastics Athlete
        let gymnast1 = Athlete(name: "Maya Johnson", sport: .gymnastics)

        modelContext.insert(skater1)
        modelContext.insert(skater2)
        modelContext.insert(gymnast1)

        // Create RunThroughs for Emma (Figure Skating)
        let emmaRun1 = createSkatingRunThrough(
            athleteID: skater1.id,
            programName: "Short Program 2026",
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            elements: [
                ("3A", nil, 15.0, 2, .clean, .correct, false, false, .stuck),
                ("3Lz", nil, 30.0, 1, .clean, .correct, false, false, .stuck),
                ("3T", nil, 45.0, 1, .clean, .correct, false, false, .stuck),
                ("CCoSp", "L4", 60.0, 2, .clean, .correct, false, false, .stuck),
                ("StSq", "L4", 75.0, 3, .clean, .correct, false, false, .stuck),
                ("3F", nil, 90.0, 2, .underRotated, .correct, false, true, .hop),
                ("SSp", "L3", 105.0, 1, .clean, .correct, false, false, .stuck)
            ]
        )

        let emmaRun2 = createSkatingRunThrough(
            athleteID: skater1.id,
            programName: "Short Program 2026",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            elements: [
                ("3A", nil, 15.0, 3, .clean, .correct, false, false, .stuck),
                ("3Lz", nil, 30.0, 2, .clean, .correct, false, false, .stuck),
                ("3T", nil, 45.0, 2, .clean, .correct, false, false, .stuck),
                ("CCoSp", "L4", 60.0, 3, .clean, .correct, false, false, .stuck),
                ("StSq", "L4", 75.0, 3, .clean, .correct, false, false, .stuck),
                ("3F", nil, 90.0, 2, .clean, .correct, false, true, .stuck),
                ("SSp", "L4", 105.0, 2, .clean, .correct, false, false, .stuck)
            ]
        )

        let emmaRun3 = createSkatingRunThrough(
            athleteID: skater1.id,
            programName: "Free Skate 2026",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            elements: [
                ("4S", nil, 20.0, 3, .clean, .correct, false, false, .stuck),
                ("3A", nil, 40.0, 2, .clean, .correct, false, false, .hop),
                ("3Lz", nil, 60.0, 1, .clean, .wrongEdge, false, false, .stuck),
                ("CCoSp", "L3", 80.0, 2, .clean, .correct, false, false, .stuck),
                ("3F", nil, 100.0, 3, .clean, .correct, false, true, .stuck),
                ("3T", nil, 120.0, 2, .clean, .correct, false, true, .stuck),
                ("StSq", "L3", 140.0, 2, .clean, .correct, false, false, .stuck),
                ("2A", nil, 160.0, 1, .clean, .correct, false, true, .stuck),
                ("ChSq", nil, 180.0, 2, .clean, .correct, false, false, .stuck)
            ]
        )

        // Create RunThroughs for Sophie (Figure Skating)
        let sophieRun1 = createSkatingRunThrough(
            athleteID: skater2.id,
            programName: "Short Program 2026",
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            elements: [
                ("3Lz", nil, 15.0, 2, .clean, .correct, false, false, .stuck),
                ("3T", nil, 30.0, 1, .clean, .correct, false, false, .stuck),
                ("3F", nil, 45.0, 1, .clean, .attention, false, false, .stuck),
                ("CCoSp", "L3", 60.0, 1, .clean, .correct, false, false, .stuck),
                ("StSq", "L3", 75.0, 1, .clean, .correct, false, false, .stuck),
                ("2A", nil, 90.0, 2, .clean, .correct, false, true, .stuck),
                ("LSp", "L2", 105.0, 1, .clean, .correct, false, false, .stuck)
            ]
        )

        // Create RunThroughs for Maya (Gymnastics)
        let mayaRun1 = createGymnasticsRunThrough(
            athleteID: gymnast1.id,
            programName: "Floor Routine 2026",
            date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
            elements: [
                ("Double Back", 30.0, 5.8, .stuck),
                ("Front Aerial", 90.0, 5.5, .step),
                ("Switch Leap", 150.0, 5.2, .stuck),
                ("Triple Twist", 210.0, 6.0, .hop)
            ]
        )

        modelContext.insert(emmaRun1)
        modelContext.insert(emmaRun2)
        modelContext.insert(emmaRun3)
        modelContext.insert(sophieRun1)
        modelContext.insert(mayaRun1)

        // Save everything
        try? modelContext.save()

        print("✅ Mock data seeded successfully!")
        print("   - 3 Athletes")
        print("   - 5 RunThroughs")
        print("   - Multiple elements per runthrough")
    }

    private static func createSkatingRunThrough(
        athleteID: UUID,
        programName: String,
        date: Date,
        elements: [(code: String, level: String?, timestamp: Double, goe: Int, rotation: RotationCall, edge: EdgeCall, isRepeat: Bool, isSecondHalf: Bool, landing: LandingType)]
    ) -> RunThrough {
        let run = RunThrough(
            athleteID: athleteID,
            programName: programName,
            sport: .skating,
            videoLocalIdentifier: "mock-video-\(UUID().uuidString)",
            date: date,
            coachNote: "Great energy! Keep working on landings and transitions."
        )

        let registry = FigureSkatingElementRegistry.shared
        var totalScore = 0.0

        for (code, level, timestamp, goe, rotation, edge, isRepeat, isSecondHalf, landing) in elements {
            // Resolve base value from registry
            var baseValue = 0.0
            if let registryElement = registry.element(forCode: code) {
                if registryElement.requiresLevel, let level = level {
                    baseValue = registryElement.levels?[level] ?? 0.0
                } else {
                    baseValue = registryElement.baseValue ?? 0.0
                }
            }

            let element = ElementScore(
                elementCode: code,
                timestamp: timestamp,
                executionValue: Double(goe),
                landing: landing,
                baseValue: baseValue,
                level: level,
                rotationCall: rotation,
                edgeCall: edge,
                isRepeat: isRepeat,
                isSecondHalf: isSecondHalf
            )

            // Calculate ISU-compliant score
            let score = element.calculatedScore(sport: .skating)
            run.elements.append(element)
            totalScore += score
        }

        run.totalScore = totalScore
        return run
    }

    private static func createGymnasticsRunThrough(
        athleteID: UUID,
        programName: String,
        date: Date,
        elements: [(code: String, timestamp: Double, score: Double, landing: LandingType)]
    ) -> RunThrough {
        let run = RunThrough(
            athleteID: athleteID,
            programName: programName,
            sport: .gymnastics,
            videoLocalIdentifier: "mock-video-\(UUID().uuidString)",
            date: date,
            coachNote: "Solid execution. Focus on sticking the landings in the next practice."
        )

        var totalScore = 0.0
        for (code, timestamp, score, landing) in elements {
            let element = ElementScore(
                elementCode: code,
                timestamp: timestamp,
                executionValue: score,
                landing: landing
            )
            run.elements.append(element)
            totalScore += score
        }

        run.totalScore = totalScore
        return run
    }
}
