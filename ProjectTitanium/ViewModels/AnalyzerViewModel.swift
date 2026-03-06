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

    private var player: AVPlayer?
    private var timeObserver: Any?

    var sportType: SportType {
        runThrough.sportType
    }

    var elements: [ElementScore] {
        runThrough.elements.sorted { $0.timestamp < $1.timestamp }
    }

    var computedTotalScore: Double {
        elements.reduce(0) { $0 + $1.executionValue }
    }

    init(runThrough: RunThrough) {
        self.runThrough = runThrough
    }

    func setupPlayer(with playerItem: AVPlayerItem) -> AVPlayer {
        let avPlayer = AVPlayer(playerItem: playerItem)
        self.player = avPlayer

        // Observe time
        let interval = CMTime(seconds: 1.0 / 30.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
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
            coachNote: coachNote.isEmpty ? nil : coachNote
        )

        runThrough.elements.append(element)
        runThrough.totalScore = computedTotalScore

        // Reset scoring state
        resetScoringState()
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
