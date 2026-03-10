import XCTest
@testable import ProjectTitanium

final class LandingTypeTests: XCTestCase {

    func testRawValues() {
        XCTAssertEqual(LandingType.stuck.rawValue, "stuck")
        XCTAssertEqual(LandingType.hop.rawValue, "hop")
        XCTAssertEqual(LandingType.step.rawValue, "step")
        XCTAssertEqual(LandingType.fall.rawValue, "fall")
    }

    func testDisplayName() {
        XCTAssertEqual(LandingType.stuck.displayName, "Stuck")
        XCTAssertEqual(LandingType.hop.displayName, "Hop")
        XCTAssertEqual(LandingType.step.displayName, "Step")
        XCTAssertEqual(LandingType.fall.displayName, "Fall")
    }

    func testIsClean() {
        XCTAssertTrue(LandingType.stuck.isClean)
        XCTAssertFalse(LandingType.hop.isClean)
        XCTAssertFalse(LandingType.step.isClean)
        XCTAssertFalse(LandingType.fall.isClean)
    }

    func testAllCases() {
        XCTAssertEqual(LandingType.allCases.count, 4)
    }

    func testCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for landing in LandingType.allCases {
            let data = try encoder.encode(landing)
            let decoded = try decoder.decode(LandingType.self, from: data)
            XCTAssertEqual(decoded, landing)
        }
    }
}
