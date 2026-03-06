import XCTest
@testable import ProjectTitanium

final class DashboardViewModelTests: XCTestCase {

    private func makeAthlete() -> Athlete {
        Athlete(name: "Test Athlete", sport: .skating)
    }

    private func makeRunThrough(
        athleteID: UUID,
        totalScore: Double,
        date: Date = Date(),
        elements: [(String, Double)] = []
    ) -> RunThrough {
        let run = RunThrough(
            athleteID: athleteID,
            sport: .skating,
            videoLocalIdentifier: "test",
            date: date,
            totalScore: totalScore
        )
        for (code, value) in elements {
            let element = ElementScore(elementCode: code, timestamp: 0, executionValue: value)
            run.elements.append(element)
        }
        return run
    }

    // MARK: - Load Data

    func testLoadDataFiltersbyAthleteID() {
        let athlete = makeAthlete()
        let otherID = UUID()

        let run1 = makeRunThrough(athleteID: athlete.id, totalScore: 50)
        let run2 = makeRunThrough(athleteID: otherID, totalScore: 60)
        let run3 = makeRunThrough(athleteID: athlete.id, totalScore: 70)

        let vm = DashboardViewModel(athlete: athlete)
        vm.loadData(from: [run1, run2, run3])

        XCTAssertEqual(vm.runThroughs.count, 2)
        XCTAssertTrue(vm.runThroughs.allSatisfy { $0.athleteID == athlete.id })
    }

    func testLoadDataSortsByDateAscending() {
        let athlete = makeAthlete()
        let date1 = Date(timeIntervalSince1970: 1000)
        let date2 = Date(timeIntervalSince1970: 2000)
        let date3 = Date(timeIntervalSince1970: 3000)

        let run1 = makeRunThrough(athleteID: athlete.id, totalScore: 50, date: date3)
        let run2 = makeRunThrough(athleteID: athlete.id, totalScore: 60, date: date1)
        let run3 = makeRunThrough(athleteID: athlete.id, totalScore: 70, date: date2)

        let vm = DashboardViewModel(athlete: athlete)
        vm.loadData(from: [run1, run2, run3])

        XCTAssertEqual(vm.runThroughs[0].date, date1)
        XCTAssertEqual(vm.runThroughs[1].date, date2)
        XCTAssertEqual(vm.runThroughs[2].date, date3)
    }

    func testLoadDataEmpty() {
        let athlete = makeAthlete()
        let vm = DashboardViewModel(athlete: athlete)
        vm.loadData(from: [])

        XCTAssertTrue(vm.runThroughs.isEmpty)
    }

    // MARK: - Trend Data

    func testTrendData() {
        let athlete = makeAthlete()
        let date1 = Date(timeIntervalSince1970: 1000)
        let date2 = Date(timeIntervalSince1970: 2000)

        let vm = DashboardViewModel(athlete: athlete)
        vm.loadData(from: [
            makeRunThrough(athleteID: athlete.id, totalScore: 50, date: date1),
            makeRunThrough(athleteID: athlete.id, totalScore: 75, date: date2),
        ])

        let trend = vm.trendData
        XCTAssertEqual(trend.count, 2)
        XCTAssertEqual(trend[0].totalScore, 50, accuracy: 0.001)
        XCTAssertEqual(trend[1].totalScore, 75, accuracy: 0.001)
    }

    func testTrendDataEmpty() {
        let athlete = makeAthlete()
        let vm = DashboardViewModel(athlete: athlete)
        vm.loadData(from: [])

        XCTAssertTrue(vm.trendData.isEmpty)
    }

    // MARK: - Heatmap Data

    func testHeatmapDataEmpty() {
        let athlete = makeAthlete()
        let vm = DashboardViewModel(athlete: athlete)
        vm.loadData(from: [])

        XCTAssertTrue(vm.heatmapData.isEmpty)
        XCTAssertTrue(vm.uniqueElementCodes.isEmpty)
    }

    func testUniqueElementCodes() {
        let athlete = makeAthlete()
        let run1 = makeRunThrough(
            athleteID: athlete.id,
            totalScore: 50,
            elements: [("3A", 2.0), ("3Lz", 1.5)]
        )
        let run2 = makeRunThrough(
            athleteID: athlete.id,
            totalScore: 60,
            elements: [("3A", 2.5), ("CCoSp4", 3.0)]
        )

        let vm = DashboardViewModel(athlete: athlete)
        vm.loadData(from: [run1, run2])

        let codes = vm.uniqueElementCodes
        XCTAssertEqual(codes, ["3A", "3Lz", "CCoSp4"]) // sorted
    }

    func testHeatmapLimitsToLast10Runs() {
        let athlete = makeAthlete()
        var runs: [RunThrough] = []
        for i in 0..<15 {
            runs.append(makeRunThrough(
                athleteID: athlete.id,
                totalScore: Double(i),
                date: Date(timeIntervalSince1970: Double(i) * 1000),
                elements: [("3A", Double(i))]
            ))
        }

        let vm = DashboardViewModel(athlete: athlete)
        vm.loadData(from: runs)

        // Heatmap should only use last 10 runs
        let runIndices = Set(vm.heatmapData.map(\.runIndex))
        XCTAssertTrue(runIndices.count <= 10)
    }

    // MARK: - HeatmapCell

    func testHeatmapCellRatio() {
        let cell = DashboardViewModel.HeatmapCell(
            elementCode: "3A",
            runIndex: 0,
            executionValue: 4.0,
            maxPossible: 5.0
        )
        XCTAssertEqual(cell.ratio, 0.8, accuracy: 0.001)
    }

    func testHeatmapCellRatioZeroMax() {
        let cell = DashboardViewModel.HeatmapCell(
            elementCode: "3A",
            runIndex: 0,
            executionValue: 4.0,
            maxPossible: 0.0
        )
        XCTAssertEqual(cell.ratio, 0.0, accuracy: 0.001)
    }

    // MARK: - TrendPoint

    func testTrendPointIdentifiable() {
        let point = DashboardViewModel.TrendPoint(date: Date(), totalScore: 50.0)
        XCTAssertNotNil(point.id)
        XCTAssertEqual(point.totalScore, 50.0, accuracy: 0.001)
    }
}
