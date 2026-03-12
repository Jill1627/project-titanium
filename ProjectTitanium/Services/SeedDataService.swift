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
                ("3A", 60.0, 8.5, .stuck),
                ("4T", 120.0, 9.8, .hop),
                ("CCoSp4", 180.0, 3.5, .stuck),
                ("StSq4", 240.0, 3.9, .stuck),
                ("3Lz+3T", 300.0, 11.2, .step)
            ]
        )

        let emmaRun2 = createSkatingRunThrough(
            athleteID: skater1.id,
            programName: "Short Program 2026",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            elements: [
                ("3A", 58.0, 8.8, .stuck),
                ("4T", 118.0, 10.2, .stuck),
                ("CCoSp4", 178.0, 3.5, .stuck),
                ("StSq4", 238.0, 3.9, .stuck),
                ("3Lz+3T", 298.0, 11.5, .stuck)
            ]
        )

        let emmaRun3 = createSkatingRunThrough(
            athleteID: skater1.id,
            programName: "Free Skate 2026",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            elements: [
                ("4S", 45.0, 9.7, .stuck),
                ("3A", 105.0, 8.2, .hop),
                ("3Lz", 165.0, 5.9, .stuck),
                ("FCSp4", 225.0, 3.2, .stuck),
                ("3F+3T", 285.0, 9.8, .stuck),
                ("ChSq1", 345.0, 3.0, .stuck)
            ]
        )

        // Create RunThroughs for Sophie (Figure Skating)
        let sophieRun1 = createSkatingRunThrough(
            athleteID: skater2.id,
            programName: "Short Program 2026",
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            elements: [
                ("3Lz+3T", 55.0, 10.5, .stuck),
                ("3F", 115.0, 5.3, .stuck),
                ("CCoSp3", 175.0, 3.0, .stuck),
                ("StSq3", 235.0, 3.3, .stuck)
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
        elements: [(code: String, timestamp: Double, score: Double, landing: LandingType)]
    ) -> RunThrough {
        let run = RunThrough(
            athleteID: athleteID,
            programName: programName,
            sport: .skating,
            videoLocalIdentifier: "mock-video-\(UUID().uuidString)",
            date: date,
            coachNote: "Great energy! Keep working on landings and transitions."
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
