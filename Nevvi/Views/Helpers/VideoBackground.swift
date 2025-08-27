//
//  VideoBackground.swift
//  Nevvi
//
//  Created by Tyler Standal on 7/2/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct VideoBackground: UIViewRepresentable {
    let videoName: String
    let videoExtension: String
    
    func makeUIView(context: Context) -> VideoPlayerView {
        return VideoPlayerView(videoName: videoName, videoExtension: videoExtension)
    }
    
    func updateUIView(_ uiView: VideoPlayerView, context: Context) {}
}

class VideoPlayerView: UIView {
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    
    init(videoName: String, videoExtension: String) {
        super.init(frame: .zero)
        setupPlayer(videoName: videoName, videoExtension: videoExtension)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlayer(videoName: String, videoExtension: String) {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else {
            print("Could not find video file: \(videoName).\(videoExtension)")
            return
        }
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        
        // Change this line to show the full video
        playerLayer?.videoGravity = .resize  // Changed from .resizeAspectFill
        playerLayer?.frame = bounds
        
        if let playerLayer = playerLayer {
            layer.addSublayer(playerLayer)
        }
        
        // Set up looping
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
        
        player?.isMuted = true
        player?.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        player?.pause()
    }
}
