import XCTest
@testable import ProjectTitanium

final class ScoringEngineTests: XCTestCase {

    // MARK: - Skating Scoring

    func testSkatingScoringSport() {
        let engine = SkatingScoring()
        XCTAssertEqual(engine.sport, .skating)
    }

    func testSkatingPositiveGOE() {
        let engine = SkatingScoring()
        // baseValue 0, GOE +3 with low scale factor (0.5)
        let score = engine.calculateScore(baseValue: 0, executionAdjustment: 3.0)
        XCTAssertEqual(score, 1.5, accuracy: 0.001) // 0 + 3.0 * 0.5
    }

    func testSkatingNegativeGOE() {
        let engine = SkatingScoring()
        let score = engine.calculateScore(baseValue: 0, executionAdjustment: -3.0)
        XCTAssertEqual(score, -1.5, accuracy: 0.001) // 0 + (-3.0) * 0.5
    }

    func testSkatingHighBaseValueScaleFactor() {
        let engine = SkatingScoring()
        // baseValue >= 8.0 → scale factor 1.0
        let score = engine.calculateScore(baseValue: 8.0, executionAdjustment: 2.0)
        XCTAssertEqual(score, 10.0, accuracy: 0.001) // 8.0 + 2.0 * 1.0
    }

    func testSkatingMidBaseValueScaleFactor() {
        let engine = SkatingScoring()
        // baseValue >= 4.0 but < 8.0 → scale factor 0.7
        let score = engine.calculateScore(baseValue: 5.0, executionAdjustment: 2.0)
        XCTAssertEqual(score, 6.4, accuracy: 0.001) // 5.0 + 2.0 * 0.7
    }

    func testSkatingLowBaseValueScaleFactor() {
        let engine = SkatingScoring()
        // baseValue < 4.0 → scale factor 0.5
        let score = engine.calculateScore(baseValue: 2.0, executionAdjustment: 2.0)
        XCTAssertEqual(score, 3.0, accuracy: 0.001) // 2.0 + 2.0 * 0.5
    }

    func testSkatingZeroGOE() {
        let engine = SkatingScoring()
        let score = engine.calculateScore(baseValue: 5.0, executionAdjustment: 0)
        XCTAssertEqual(score, 5.0, accuracy: 0.001)
    }

    // MARK: - Gymnastics Scoring

    func testGymnasticsScoringPort() {
        let engine = GymnasticsScoring()
        XCTAssertEqual(engine.sport, .gymnastics)
    }

    func testGymnasticsNoDeductions() {
        let engine = GymnasticsScoring()
        let score = engine.calculateScore(baseValue: 6.0, executionAdjustment: 0)
        XCTAssertEqual(score, 6.0, accuracy: 0.001)
    }

    func testGymnasticsWithDeductions() {
        let engine = GymnasticsScoring()
        // D-Score 6.0 with -1.5 in deductions
        let score = engine.calculateScore(baseValue: 6.0, executionAdjustment: -1.5)
        XCTAssertEqual(score, 4.5, accuracy: 0.001)
    }

    func testGymnasticsScoreFloorsAtZero() {
        let engine = GymnasticsScoring()
        // Deductions exceed base value — floor at 0
        let score = engine.calculateScore(baseValue: 2.0, executionAdjustment: -5.0)
        XCTAssertEqual(score, 0.0, accuracy: 0.001)
    }

    func testGymnasticsLargeDeduction() {
        let engine = GymnasticsScoring()
        let score = engine.calculateScore(baseValue: 10.0, executionAdjustment: -10.0)
        XCTAssertEqual(score, 0.0, accuracy: 0.001)
    }

    // MARK: - Factory

    func testFactoryReturnsSkatingEngine() {
        let engine = ScoringEngineFactory.engine(for: .skating)
        XCTAssertEqual(engine.sport, .skating)
    }

    func testFactoryReturnsGymnasticsEngine() {
        let engine = ScoringEngineFactory.engine(for: .gymnastics)
        XCTAssertEqual(engine.sport, .gymnastics)
    }
}
