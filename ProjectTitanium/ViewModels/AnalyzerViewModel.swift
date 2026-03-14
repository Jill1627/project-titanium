import AVFoundation
import Combine
import SwiftData
import SwiftUI

@Observable
final class AnalyzerViewModel {
    var runThrough: RunThrough
    var currentTime: Double = 0
    var duration: Double = 0
    var isPlaying = false
    var playbackRate: Float = 1.0

    // Scoring state
    var selectedElementCode: String = ""
    var currentGOE: Double = 0
    var currentDeductions: Double = 0
    var selectedLanding: LandingType = .stuck
    var coachNote: String = ""

    // Figure skating technical scoring
    var baseValue: Double = 10.0  // Default stub value for skating elements
    var rotationCall: RotationCall = .clean
    var edgeCall: EdgeCall = .correct
    var isRepeat: Bool = false
    var isSecondHalf: Bool = false

    // PPC pre-loaded element codes for one-tap review
    var ppcElementCodes: [String] = []
    var ppcCurrentIndex: Int = 0

    private var player: AVPlayer?
    private var timeObserver: Any?
    private let scoringEngine: ScoringEngine

    var sportType: SportType {
        runThrough.sportType
    }

    var hasPPC: Bool {
        !ppcElementCodes.isEmpty
    }

    var nextPPCElement: String? {
        guard ppcCurrentIndex < ppcElementCodes.count else { return nil }
        return ppcElementCodes[ppcCurrentIndex]
    }

    var elements: [ElementScore] {
        runThrough.elements.sorted { $0.timestamp < $1.timestamp }
    }

    var computedTotalScore: Double {
        runThrough.calculatedTotalScore
    }

    init(runThrough: RunThrough, ppcElementCodes: [String] = []) {
        self.runThrough = runThrough
        self.scoringEngine = ScoringEngineFactory.engine(for: runThrough.sportType)
        self.ppcElementCodes = ppcElementCodes
        if let first = ppcElementCodes.first {
            self.selectedElementCode = first
        }
    }

    func setupPlayer(with playerItem: AVPlayerItem) -> AVPlayer {
        let avPlayer = AVPlayer(playerItem: playerItem)
        self.player = avPlayer

        // Observe time
        let interval = CMTime(seconds: 1.0 / 60.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }

        // Get duration
        Task { @MainActor in
            if let dur = try? await playerItem.asset.load(.duration) {
                self.duration = dur.seconds
            }
        }

        return avPlayer
    }

    func togglePlayback() {
        guard let player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.rate = playbackRate
        }
        isPlaying.toggle()
    }

    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
        if isPlaying {
            player?.rate = rate
        }
    }

    // MARK: - Scoring

    func syncElement(modelContext: ModelContext) {
        guard !selectedElementCode.isEmpty else { return }

        // Store raw execution value (GOE for skating, -deductions for gymnastics)
        let executionValue: Double
        if sportType == .skating {
            executionValue = currentGOE
        } else {
            executionValue = -currentDeductions
        }

        let element = ElementScore(
            elementCode: selectedElementCode,
            timestamp: currentTime,
            executionValue: executionValue,
            landing: selectedLanding,
            coachNote: coachNote.isEmpty ? nil : coachNote,
            baseValue: baseValue,
            rotationCall: rotationCall,
            edgeCall: edgeCall,
            isRepeat: isRepeat,
            isSecondHalf: isSecondHalf
        )

        runThrough.elements.append(element)
        runThrough.totalScore = computedTotalScore

        // Advance PPC index if using one-tap review
        if hasPPC {
            ppcCurrentIndex += 1
        }

        // Reset scoring state, pre-load next PPC element
        resetScoringState()
        if let next = nextPPCElement {
            selectedElementCode = next
        }
    }

    func removeElement(_ element: ElementScore, modelContext: ModelContext) {
        runThrough.elements.removeAll { $0.id == element.id }
        modelContext.delete(element)
        runThrough.totalScore = computedTotalScore
    }

    func resetScoringState() {
        selectedElementCode = ""
        currentGOE = 0
        currentDeductions = 0
        selectedLanding = .stuck
        coachNote = ""
        baseValue = sportType == .skating ? 10.0 : 0.0
        rotationCall = .clean
        edgeCall = .correct
        isRepeat = false
        isSecondHalf = false
    }

    func addDeduction(_ value: Double) {
        currentDeductions += value
    }

    deinit {
        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
        }
    }
}
