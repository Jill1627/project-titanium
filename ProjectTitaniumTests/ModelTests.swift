import XCTest
@testable import ProjectTitanium

final class AthleteModelTests: XCTestCase {

    func testAthleteInit() {
        let athlete = Athlete(name: "Emma", sport: .skating)
        XCTAssertEqual(athlete.name, "Emma")
        XCTAssertEqual(athlete.sport, "skating")
        XCTAssertEqual(athlete.sportType, .skating)
        XCTAssertNotNil(athlete.id)
        XCTAssertNotNil(athlete.createdAt)
    }

    func testAthleteSportTypeAccessor() {
        let athlete = Athlete(name: "Jack", sport: .gymnastics)
        XCTAssertEqual(athlete.sportType, .gymnastics)

        athlete.sportType = .skating
        XCTAssertEqual(athlete.sport, "skating")
        XCTAssertEqual(athlete.sportType, .skating)
    }

    func testAthleteInvalidSportDefaultsToSkating() {
        let athlete = Athlete(name: "Test", sport: .skating)
        athlete.sport = "invalid"
        XCTAssertEqual(athlete.sportType, .skating) // default fallback
    }
}

final class ElementScoreModelTests: XCTestCase {

    func testElementScoreInit() {
        let element = ElementScore(
            elementCode: "3A",
            timestamp: 45.5,
            executionValue: 2.0,
            landing: .stuck,
            coachNote: "Clean landing"
        )

        XCTAssertEqual(element.elementCode, "3A")
        XCTAssertEqual(element.timestamp, 45.5, accuracy: 0.001)
        XCTAssertEqual(element.executionValue, 2.0, accuracy: 0.001)
        XCTAssertEqual(element.landing, "stuck")
        XCTAssertEqual(element.landingType, .stuck)
        XCTAssertEqual(element.coachNote, "Clean landing")
        XCTAssertNotNil(element.id)
        XCTAssertNotNil(element.createdAt)
    }

    func testElementScoreDefaults() {
        let element = ElementScore(elementCode: "2Lz", timestamp: 10.0)
        XCTAssertEqual(element.executionValue, 0.0, accuracy: 0.001)
        XCTAssertEqual(element.landingType, .stuck)
        XCTAssertNil(element.coachNote)
    }

    func testLandingTypeAccessor() {
        let element = ElementScore(elementCode: "3F", timestamp: 20.0, landing: .fall)
        XCTAssertEqual(element.landingType, .fall)
        XCTAssertFalse(element.landingType.isClean)

        element.landingType = .stuck
        XCTAssertEqual(element.landing, "stuck")
        XCTAssertTrue(element.landingType.isClean)
    }

    func testInvalidLandingDefaultsToStuck() {
        let element = ElementScore(elementCode: "2A", timestamp: 5.0)
        element.landing = "invalid"
        XCTAssertEqual(element.landingType, .stuck) // default fallback
    }
}

final class RunThroughModelTests: XCTestCase {

    func testRunThroughInit() {
        let athleteID = UUID()
        let run = RunThrough(
            athleteID: athleteID,
            sport: .skating,
            videoLocalIdentifier: "PHAsset/12345"
        )

        XCTAssertEqual(run.athleteID, athleteID)
        XCTAssertEqual(run.sport, "skating")
        XCTAssertEqual(run.sportType, .skating)
        XCTAssertEqual(run.videoLocalIdentifier, "PHAsset/12345")
        XCTAssertEqual(run.totalScore, 0.0, accuracy: 0.001)
        XCTAssertTrue(run.elements.isEmpty)
        XCTAssertNotNil(run.id)
    }

    func testRunThroughSportTypeAccessor() {
        let run = RunThrough(
            athleteID: UUID(),
            sport: .gymnastics,
            videoLocalIdentifier: "test"
        )
        XCTAssertEqual(run.sportType, .gymnastics)

        run.sportType = .skating
        XCTAssertEqual(run.sport, "skating")
    }

    func testRunThroughCustomDate() {
        let date = Date(timeIntervalSince1970: 1000000)
        let run = RunThrough(
            athleteID: UUID(),
            sport: .skating,
            videoLocalIdentifier: "test",
            date: date
        )
        XCTAssertEqual(run.date, date)
    }

    func testRunThroughCustomTotalScore() {
        let run = RunThrough(
            athleteID: UUID(),
            sport: .skating,
            videoLocalIdentifier: "test",
            totalScore: 75.5
        )
        XCTAssertEqual(run.totalScore, 75.5, accuracy: 0.001)
    }
}

final class PlannedProgramContentModelTests: XCTestCase {

    func testPPCInit() {
        let ppc = PlannedProgramContent(
            name: "Short Program",
            sport: .skating,
            elementCodes: ["3A", "3Lz+3T", "CCoSp4"]
        )

        XCTAssertEqual(ppc.name, "Short Program")
        XCTAssertEqual(ppc.sport, "skating")
        XCTAssertEqual(ppc.sportType, .skating)
        XCTAssertEqual(ppc.elementCodes, ["3A", "3Lz+3T", "CCoSp4"])
        XCTAssertNotNil(ppc.id)
    }

    func testPPCEmptyElements() {
        let ppc = PlannedProgramContent(name: "Empty", sport: .gymnastics)
        XCTAssertTrue(ppc.elementCodes.isEmpty)
    }

    func testPPCSportTypeAccessor() {
        let ppc = PlannedProgramContent(name: "Test", sport: .skating)
        ppc.sportType = .gymnastics
        XCTAssertEqual(ppc.sport, "gymnastics")
    }
}
