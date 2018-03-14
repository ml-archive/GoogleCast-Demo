//
//  Player.swift
//  NodesCast
//
//  Created by Andrei Hogea on 14/03/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//

import UIKit
import AVFoundation

enum PlaybackState {
    case createdCast
    case created
    case playCast
    case play
    case pauseCast
    case pause
    case finishedCast
    case finished
}

class Player: UIView {
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var playbackState: PlaybackState = .created
    
    private var playPauseButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        initPlayerLayer()
        createPlayPauseButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initPlayerLayer() {
        guard let url = URL(string: "https://devimages-cdn.apple.com/samplecode/avfoundationMedia/AVFoundationQueuePlayer_HLS2/master.m3u8") else { return }
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        layer.addSublayer(playerLayer)
        playerLayer.frame = bounds
    }
    
    // MARK: - Play/Pause/Replay Button
    
    private func createPlayPauseButton() {
        playPauseButton = UIButton()
        playPauseButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        playPauseButton.setTitle("", for: .normal)
        playPauseButton.layer.cornerRadius = 40/2
        playPauseButton.clipsToBounds = true
        playPauseButton.backgroundColor = UIColor.black.withAlphaComponent(0.64)
        addSubview(playPauseButton)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        changeToPlayButton()
    }
    
    // MARK: Play Button Change
    
    private func changeToPlayButton() {
        guard let playPauseButton = playPauseButton else { return }
        playPauseButton.removeTarget(self, action: nil, for: .allEvents)
        playPauseButton.setImage(#imageLiteral(resourceName: "icon_play"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(startPlayer(_:)), for: .touchUpInside)
    }
    
    // MARK: Pause Button Change
    
    private func changeToPauseButton() {
        guard let playPauseButton = playPauseButton else { return }
        playPauseButton.removeTarget(self, action: nil, for: .allEvents)
        playPauseButton.setImage(#imageLiteral(resourceName: "icon_pause"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(pausePlayer(_:)), for: .touchUpInside)
    }
    
    // MARK: Start Player
    
    @objc private func startPlayer(_ sender: Any?) {
        player?.play()
        playbackState = .play
        changeToPauseButton()
    }

    // MARK: Pause Player
    
    @objc private func pausePlayer(_ sender: Any?) {
        player?.pause()
        playbackState = .pause
        changeToPlayButton()
    }

}
