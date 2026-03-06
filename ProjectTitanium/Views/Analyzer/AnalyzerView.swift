import AVFoundation
import Photos
import SwiftData
import SwiftUI

struct AnalyzerView: View {
    @Environment(\.modelContext) private var modelContext
    @State var viewModel: AnalyzerViewModel
    @State private var player: AVPlayer?
    @State private var showingElementTimeline = true

    private let hapticsService = HapticsService()

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .navigationTitle("Analyzer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach([0.25, 0.5, 1.0, 2.0], id: \.self) { rate in
                        Button {
                            viewModel.setPlaybackRate(Float(rate))
                        } label: {
                            HStack {
                                Text("\(rate, specifier: "%.2f")x")
                                if viewModel.playbackRate == Float(rate) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label("Speed", systemImage: "speedometer")
                }
            }
        }
        .onAppear {
            loadVideo()
        }
    }

    // MARK: - Portrait Layout

    private var portraitLayout: some View {
        VStack(spacing: 0) {
            // Video player
            if let player {
                VideoPlayerView(player: player)
                    .frame(height: 260)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 260)
                    .overlay {
                        ProgressView()
                    }
            }

            // Scrubber
            videoScrubber
                .padding(.horizontal)
                .padding(.top, 8)

            // Playback controls
            playbackControls
                .padding(.vertical, 8)

            Divider()

            // Landing buttons
            LandingButtonsView(
                selectedLanding: $viewModel.selectedLanding,
                hapticsService: hapticsService
            )
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Scoring tray
            ScoringTrayView(viewModel: viewModel, hapticsService: hapticsService)
                .padding(.horizontal)

            // Sync button
            syncButton
                .padding()

            Divider()

            // Element timeline
            ElementTimelineView(
                elements: viewModel.elements,
                duration: viewModel.duration,
                onSeek: { viewModel.seek(to: $0) },
                onDelete: { viewModel.removeElement($0, modelContext: modelContext) }
            )
            .frame(maxHeight: .infinity)
        }
    }

    // MARK: - Landscape Layout

    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            // Video + controls
            VStack(spacing: 8) {
                if let player {
                    VideoPlayerView(player: player)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay { ProgressView() }
                }

                videoScrubber
                    .padding(.horizontal)

                playbackControls
            }
            .frame(maxWidth: .infinity)

            Divider()

            // Scoring panel
            ScrollView {
                VStack(spacing: 12) {
                    LandingButtonsView(
                        selectedLanding: $viewModel.selectedLanding,
                        hapticsService: hapticsService
                    )

                    ScoringTrayView(viewModel: viewModel, hapticsService: hapticsService)

                    syncButton

                    Divider()

                    ElementTimelineView(
                        elements: viewModel.elements,
                        duration: viewModel.duration,
                        onSeek: { viewModel.seek(to: $0) },
                        onDelete: { viewModel.removeElement($0, modelContext: modelContext) }
                    )
                }
                .padding()
            }
            .frame(width: 320)
        }
    }

    // MARK: - Controls

    private var videoScrubber: some View {
        VStack(spacing: 4) {
            Slider(
                value: Binding(
                    get: { viewModel.currentTime },
                    set: { viewModel.seek(to: $0) }
                ),
                in: 0...max(viewModel.duration, 1)
            )
            .tint(.accentColor)

            HStack {
                Text(formatTime(viewModel.currentTime))
                Spacer()
                Text(formatTime(viewModel.duration))
            }
            .font(.caption2)
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 32) {
            // Frame back
            Button {
                viewModel.seek(to: max(0, viewModel.currentTime - 1.0 / 30.0))
            } label: {
                Image(systemName: "backward.frame")
                    .font(.title3)
            }

            // Play/Pause
            Button {
                viewModel.togglePlayback()
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.largeTitle)
            }

            // Frame forward
            Button {
                viewModel.seek(to: min(viewModel.duration, viewModel.currentTime + 1.0 / 30.0))
            } label: {
                Image(systemName: "forward.frame")
                    .font(.title3)
            }
        }
        .foregroundStyle(.primary)
    }

    private var syncButton: some View {
        Button {
            viewModel.syncElement(modelContext: modelContext)
            hapticsService.playStuckLanding()
        } label: {
            Label("Sync Element", systemImage: "pin.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(viewModel.selectedElementCode.isEmpty ? Color.gray : Color.accentColor)
                )
        }
        .disabled(viewModel.selectedElementCode.isEmpty)
    }

    // MARK: - Helpers

    private func loadVideo() {
        let identifier = viewModel.runThrough.videoLocalIdentifier
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let asset = result.firstObject else { return }

        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat

        PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { playerItem, _ in
            guard let playerItem else { return }
            DispatchQueue.main.async {
                self.player = self.viewModel.setupPlayer(with: playerItem)
            }
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
