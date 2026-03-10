import XCTest
@testable import ProjectTitanium

final class SportTypeTests: XCTestCase {

    func testRawValues() {
        XCTAssertEqual(SportType.skating.rawValue, "skating")
        XCTAssertEqual(SportType.gymnastics.rawValue, "gymnastics")
    }

    func testDisplayName() {
        XCTAssertEqual(SportType.skating.displayName, "Figure Skating")
        XCTAssertEqual(SportType.gymnastics.displayName, "Gymnastics")
    }

    func testIconName() {
        XCTAssertEqual(SportType.skating.iconName, "figure.skating")
        XCTAssertEqual(SportType.gymnastics.iconName, "figure.gymnastics")
    }

    func testAllCases() {
        XCTAssertEqual(SportType.allCases.count, 2)
        XCTAssertTrue(SportType.allCases.contains(.skating))
        XCTAssertTrue(SportType.allCases.contains(.gymnastics))
    }

    func testIdentifiable() {
        XCTAssertEqual(SportType.skating.id, "skating")
        XCTAssertEqual(SportType.gymnastics.id, "gymnastics")
    }

    func testCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(SportType.skating)
        let decoded = try decoder.decode(SportType.self, from: data)
        XCTAssertEqual(decoded, .skating)
    }
}
