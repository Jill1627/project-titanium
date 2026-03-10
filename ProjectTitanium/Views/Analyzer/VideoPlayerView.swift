import AVFoundation
import SwiftUI

struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {}
}

final class PlayerUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    private var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspect
        setupPinchZoom()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPinchZoom() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinch)
        isUserInteractionEnabled = true
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let scale = gesture.scale
            let currentTransform = transform
            let newTransform = currentTransform.scaledBy(x: scale, y: scale)
            // Clamp between 1x and 4x
            let clampedScale = min(max(newTransform.a, 1.0), 4.0)
            transform = CGAffineTransform(scaleX: clampedScale, y: clampedScale)
            gesture.scale = 1.0
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.3) {
                self.transform = .identity
            }
        default:
            break
        }
    }
}
