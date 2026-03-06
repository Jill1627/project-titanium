import XCTest
@testable import ProjectTitanium

final class AnalyzerViewModelTests: XCTestCase {

    private func makeRunThrough(sport: SportType = .skating) -> RunThrough {
        RunThrough(
            athleteID: UUID(),
            sport: sport,
            videoLocalIdentifier: "test-video-id"
        )
    }

    // MARK: - Initialization

    func testInitWithRunThrough() {
        let run = makeRunThrough(sport: .skating)
        let vm = AnalyzerViewModel(runThrough: run)

        XCTAssertEqual(vm.sportType, .skating)
        XCTAssertEqual(vm.currentTime, 0)
        XCTAssertEqual(vm.duration, 0)
        XCTAssertFalse(vm.isPlaying)
        XCTAssertEqual(vm.playbackRate, 1.0)
        XCTAssertEqual(vm.selectedElementCode, "")
        XCTAssertEqual(vm.currentGOE, 0)
        XCTAssertEqual(vm.currentDeductions, 0)
        XCTAssertEqual(vm.selectedLanding, .stuck)
        XCTAssertEqual(vm.coachNote, "")
        XCTAssertTrue(vm.elements.isEmpty)
    }

    func testInitWithPPC() {
        let run = makeRunThrough()
        let codes = ["3A", "3Lz", "CCoSp4"]
        let vm = AnalyzerViewModel(runThrough: run, ppcElementCodes: codes)

        XCTAssertTrue(vm.hasPPC)
        XCTAssertEqual(vm.ppcElementCodes, codes)
        XCTAssertEqual(vm.ppcCurrentIndex, 0)
        XCTAssertEqual(vm.selectedElementCode, "3A") // Pre-loaded first element
        XCTAssertEqual(vm.nextPPCElement, "3A")
    }

    func testInitWithoutPPC() {
        let run = makeRunThrough()
        let vm = AnalyzerViewModel(runThrough: run)

        XCTAssertFalse(vm.hasPPC)
        XCTAssertTrue(vm.ppcElementCodes.isEmpty)
    }

    // MARK: - Sport Type

    func testSportTypeSkating() {
        let vm = AnalyzerViewModel(runThrough: makeRunThrough(sport: .skating))
        XCTAssertEqual(vm.sportType, .skating)
    }

    func testSportTypeGymnastics() {
        let vm = AnalyzerViewModel(runThrough: makeRunThrough(sport: .gymnastics))
        XCTAssertEqual(vm.sportType, .gymnastics)
    }

    // MARK: - Computed Total Score

    func testComputedTotalScoreEmpty() {
        let vm = AnalyzerViewModel(runThrough: makeRunThrough())
        XCTAssertEqual(vm.computedTotalScore, 0, accuracy: 0.001)
    }

    func testComputedTotalScoreWithElements() {
        let run = makeRunThrough()
        let e1 = ElementScore(elementCode: "3A", timestamp: 10, executionValue: 2.5)
        let e2 = ElementScore(elementCode: "3Lz", timestamp: 20, executionValue: 1.5)
        run.elements = [e1, e2]

        let vm = AnalyzerViewModel(runThrough: run)
        XCTAssertEqual(vm.computedTotalScore, 4.0, accuracy: 0.001)
    }

    // MARK: - Elements Sorted by Timestamp

    func testElementsSortedByTimestamp() {
        let run = makeRunThrough()
        let e1 = ElementScore(elementCode: "3A", timestamp: 30)
        let e2 = ElementScore(elementCode: "2Lz", timestamp: 10)
        let e3 = ElementScore(elementCode: "CCoSp", timestamp: 20)
        run.elements = [e1, e2, e3]

        let vm = AnalyzerViewModel(runThrough: run)
        let codes = vm.elements.map(\.elementCode)
        XCTAssertEqual(codes, ["2Lz", "CCoSp", "3A"])
    }

    // MARK: - Playback Rate

    func testSetPlaybackRate() {
        let vm = AnalyzerViewModel(runThrough: makeRunThrough())
        vm.setPlaybackRate(0.25)
        XCTAssertEqual(vm.playbackRate, 0.25)
    }

    // MARK: - Deductions

    func testAddDeduction() {
        let vm = AnalyzerViewModel(runThrough: makeRunThrough(sport: .gymnastics))
        XCTAssertEqual(vm.currentDeductions, 0)

        vm.addDeduction(0.1)
        XCTAssertEqual(vm.currentDeductions, 0.1, accuracy: 0.001)

        vm.addDeduction(0.3)
        XCTAssertEqual(vm.currentDeductions, 0.4, accuracy: 0.001)

        vm.addDeduction(0.5)
        XCTAssertEqual(vm.currentDeductions, 0.9, accuracy: 0.001)
    }

    // MARK: - Reset Scoring State

    func testResetScoringState() {
        let vm = AnalyzerViewModel(runThrough: makeRunThrough())
        vm.selectedElementCode = "3A"
        vm.currentGOE = 3.0
        vm.currentDeductions = 1.0
        vm.selectedLanding = .fall
        vm.coachNote = "Some note"

        vm.resetScoringState()

        XCTAssertEqual(vm.selectedElementCode, "")
        XCTAssertEqual(vm.currentGOE, 0)
        XCTAssertEqual(vm.currentDeductions, 0)
        XCTAssertEqual(vm.selectedLanding, .stuck)
        XCTAssertEqual(vm.coachNote, "")
    }

    // MARK: - PPC Navigation

    func testPPCAdvancesAfterSync() {
        // Note: syncElement requires ModelContext which needs SwiftData container.
        // This test verifies PPC index tracking logic separately.
        let run = makeRunThrough()
        let codes = ["3A", "3Lz", "CCoSp4"]
        let vm = AnalyzerViewModel(runThrough: run, ppcElementCodes: codes)

        XCTAssertEqual(vm.ppcCurrentIndex, 0)
        XCTAssertEqual(vm.nextPPCElement, "3A")

        // Simulate advancing
        vm.ppcCurrentIndex = 1
        XCTAssertEqual(vm.nextPPCElement, "3Lz")

        vm.ppcCurrentIndex = 2
        XCTAssertEqual(vm.nextPPCElement, "CCoSp4")

        vm.ppcCurrentIndex = 3
        XCTAssertNil(vm.nextPPCElement) // Past end
    }

    // MARK: - Toggle Playback (without AVPlayer)

    func testTogglePlaybackWithoutPlayer() {
        let vm = AnalyzerViewModel(runThrough: makeRunThrough())
        // Without a player setup, togglePlayback should be a no-op
        vm.togglePlayback()
        // isPlaying shouldn't change without a player
        XCTAssertFalse(vm.isPlaying)
    }
}
