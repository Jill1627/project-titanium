import XCTest
@testable import ProjectTitanium

/// Integration tests verifying cross-component interactions
final class ScoringIntegrationTests: XCTestCase {

    // MARK: - Skating End-to-End Scoring

    func testSkatingFullScoringFlow() {
        // Create athlete and run
        let athlete = Athlete(name: "Yuna", sport: .skating)
        let run = RunThrough(
            athleteID: athlete.id,
            sport: .skating,
            videoLocalIdentifier: "test-video"
        )

        // Create ViewModel (uses ScoringEngine internally)
        let vm = AnalyzerViewModel(runThrough: run)
        XCTAssertEqual(vm.sportType, .skating)

        // Simulate scoring an element with positive GOE
        vm.selectedElementCode = "3A"
        vm.currentGOE = 3.0
        vm.selectedLanding = .stuck

        // Verify scoring engine would produce the right value
        let engine = ScoringEngineFactory.engine(for: .skating)
        let score = engine.calculateScore(baseValue: 0, executionAdjustment: 3.0)
        XCTAssertEqual(score, 1.5, accuracy: 0.001) // GOE 3.0 * 0.5 scale

        // Verify landing is clean
        XCTAssertTrue(vm.selectedLanding.isClean)
    }

    func testSkatingNegativeGOEFlow() {
        let run = RunThrough(
            athleteID: UUID(),
            sport: .skating,
            videoLocalIdentifier: "test"
        )

        let vm = AnalyzerViewModel(runThrough: run)
        vm.selectedElementCode = "3Lz"
        vm.currentGOE = -2.0
        vm.selectedLanding = .fall

        let engine = ScoringEngineFactory.engine(for: .skating)
        let score = engine.calculateScore(baseValue: 0, executionAdjustment: -2.0)
        XCTAssertLessThan(score, 0)
        XCTAssertFalse(vm.selectedLanding.isClean)
    }

    // MARK: - Gymnastics End-to-End Scoring

    func testGymnasticsFullScoringFlow() {
        let athlete = Athlete(name: "Simone", sport: .gymnastics)
        let run = RunThrough(
            athleteID: athlete.id,
            sport: .gymnastics,
            videoLocalIdentifier: "test-video"
        )

        let vm = AnalyzerViewModel(runThrough: run)
        XCTAssertEqual(vm.sportType, .gymnastics)

        // Add deductions
        vm.addDeduction(0.1)
        vm.addDeduction(0.3)
        XCTAssertEqual(vm.currentDeductions, 0.4, accuracy: 0.001)

        let engine = ScoringEngineFactory.engine(for: .gymnastics)
        let score = engine.calculateScore(baseValue: 6.0, executionAdjustment: -0.4)
        XCTAssertEqual(score, 5.6, accuracy: 0.001)
    }

    func testGymnasticsSevereFallDeductions() {
        let run = RunThrough(
            athleteID: UUID(),
            sport: .gymnastics,
            videoLocalIdentifier: "test"
        )

        let vm = AnalyzerViewModel(runThrough: run)
        vm.addDeduction(1.0)
        vm.addDeduction(1.0)
        vm.addDeduction(1.0)
        XCTAssertEqual(vm.currentDeductions, 3.0, accuracy: 0.001)

        let engine = ScoringEngineFactory.engine(for: .gymnastics)
        let score = engine.calculateScore(baseValue: 2.0, executionAdjustment: -3.0)
        XCTAssertEqual(score, 0, accuracy: 0.001) // Floored at 0
    }

    // MARK: - PPC Integration

    func testPPCWithAnalyzerViewModel() {
        let athlete = Athlete(name: "Test", sport: .skating)
        let run = RunThrough(
            athleteID: athlete.id,
            sport: .skating,
            videoLocalIdentifier: "test"
        )

        let ppcCodes = ["3A", "3Lz+3T", "CCoSp4", "StSq3"]
        let vm = AnalyzerViewModel(runThrough: run, ppcElementCodes: ppcCodes)

        // First element should be pre-loaded
        XCTAssertEqual(vm.selectedElementCode, "3A")
        XCTAssertTrue(vm.hasPPC)
        XCTAssertEqual(vm.ppcCurrentIndex, 0)

        // After advancing, next element should be ready
        vm.ppcCurrentIndex = 1
        XCTAssertEqual(vm.nextPPCElement, "3Lz+3T")

        // Past end
        vm.ppcCurrentIndex = 4
        XCTAssertNil(vm.nextPPCElement)
    }

    func testPPCModelMatchesSport() {
        let skatingPPC = PlannedProgramContent(
            name: "Short Program",
            sport: .skating,
            elementCodes: ["3A", "3Lz+3T"]
        )
        let gymnasticsPPC = PlannedProgramContent(
            name: "Floor Routine",
            sport: .gymnastics,
            elementCodes: ["FX", "BHS"]
        )

        XCTAssertEqual(skatingPPC.sportType, .skating)
        XCTAssertEqual(gymnasticsPPC.sportType, .gymnastics)
        XCTAssertNotEqual(skatingPPC.sport, gymnasticsPPC.sport)
    }

    // MARK: - Dashboard Integration

    func testDashboardWithMultipleAthletes() {
        let athlete1 = Athlete(name: "Athlete A", sport: .skating)
        let athlete2 = Athlete(name: "Athlete B", sport: .skating)

        let run1 = RunThrough(athleteID: athlete1.id, sport: .skating, videoLocalIdentifier: "v1", totalScore: 50)
        let run2 = RunThrough(athleteID: athlete2.id, sport: .skating, videoLocalIdentifier: "v2", totalScore: 70)
        let run3 = RunThrough(athleteID: athlete1.id, sport: .skating, videoLocalIdentifier: "v3", totalScore: 60)

        let vm = DashboardViewModel(athlete: athlete1)
        vm.loadData(from: [run1, run2, run3])

        // Should only show athlete1's runs
        XCTAssertEqual(vm.runThroughs.count, 2)
        XCTAssertEqual(vm.trendData.count, 2)
        XCTAssertEqual(vm.trendData[0].totalScore, 50, accuracy: 0.001)
        XCTAssertEqual(vm.trendData[1].totalScore, 60, accuracy: 0.001)
    }

    func testDashboardHeatmapConsistency() {
        let athlete = Athlete(name: "Test", sport: .skating)

        let run1 = RunThrough(
            athleteID: athlete.id, sport: .skating,
            videoLocalIdentifier: "v1",
            date: Date(timeIntervalSince1970: 1000)
        )
        run1.elements.append(ElementScore(elementCode: "3A", timestamp: 10, executionValue: 5.0))
        run1.elements.append(ElementScore(elementCode: "3Lz", timestamp: 20, executionValue: 3.0))

        let run2 = RunThrough(
            athleteID: athlete.id, sport: .skating,
            videoLocalIdentifier: "v2",
            date: Date(timeIntervalSince1970: 2000)
        )
        run2.elements.append(ElementScore(elementCode: "3A", timestamp: 10, executionValue: 4.0))
        // 3Lz not performed in run2

        let vm = DashboardViewModel(athlete: athlete)
        vm.loadData(from: [run1, run2])

        let codes = vm.uniqueElementCodes
        XCTAssertEqual(codes, ["3A", "3Lz"])

        // Heatmap should have cells for both elements across both runs
        XCTAssertEqual(vm.heatmapData.count, 4) // 2 elements x 2 runs
    }

    // MARK: - Model Relationship Integrity

    func testRunThroughElementRelationship() {
        let run = RunThrough(
            athleteID: UUID(),
            sport: .skating,
            videoLocalIdentifier: "test"
        )

        let e1 = ElementScore(elementCode: "3A", timestamp: 10, executionValue: 2.0)
        let e2 = ElementScore(elementCode: "3Lz", timestamp: 25, executionValue: 1.5)

        run.elements.append(e1)
        run.elements.append(e2)

        XCTAssertEqual(run.elements.count, 2)

        // Verify total can be computed
        let total = run.elements.reduce(0) { $0 + $1.executionValue }
        XCTAssertEqual(total, 3.5, accuracy: 0.001)
    }

    func testAthleteToRunThroughIDLinkage() {
        let athlete = Athlete(name: "Test", sport: .skating)
        let run = RunThrough(
            athleteID: athlete.id,
            sport: .skating,
            videoLocalIdentifier: "test"
        )

        XCTAssertEqual(run.athleteID, athlete.id)
        XCTAssertEqual(run.sport, athlete.sport)
    }
}
