//
//  Player.swift
//  NodesCast
//
//  Created by Andrei Hogea on 14/03/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleCast

enum PlaybackState {
    case created
    case playCast
    case play
    case pauseCast
    case pause
    case finishedCast
    case finished
}

class Player: UIView {
    
    var mediaItem: MediaItem!
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var playbackState: PlaybackState = .created
    
    private var playPauseButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        listenForCastConnection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPlayerLayer() {
        guard let url = URL(string: mediaItem.videoUrl) else { return }
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        layer.addSublayer(playerLayer)
        playerLayer.frame = bounds
        
        createPlayPauseButton()
    }
    
    // MARK: - Add Cast Connection Listener
    
    private func listenForCastConnection() {
        let sessionStatusListener: (CastSessionStatus) -> Void = { status in
            switch status {
            case .started:
                self.startCastPlay()
            case .resumed:
                self.continueCastPlay()
            case .alreadyConnected:
                break
            case .ended, .failedToStart:
                if self.playbackState == .playCast {
                    self.playbackState = .pause
                    self.startPlayer(nil)
                } else if self.playbackState == .pauseCast {
                    self.playbackState = .play
                    self.pausePlayer(nil)
                }
            }
        }
        
        CastManager.shared.addSessionStatusListener(listener: sessionStatusListener)

    }
    
    private func startCastPlay() {
        guard let currentItem = player.currentItem else { return }
        let duration = currentItem.asset.duration.seconds
        playbackState = .playCast
        player.pause()
        let castMediaInfo = CastManager.shared.buildMediaInformation(with: mediaItem.name, with: mediaItem.about, with: "Nodes", with: duration, with: mediaItem.videoUrl, with: GCKMediaStreamType.buffered, with: nil, with: nil, with: mediaItem.thumbnailUrl)
        CastManager.shared.startSelectedItemRemotely(castMediaInfo, at: player.currentTime().seconds, completion: { done in
            if !done {
                self.playbackState = .pause
                self.startPlayer(nil)
            }
        })
    }
    
    private func continueCastPlay() {
        let durationCurrent = player.currentTime().seconds
        playbackState = .playCast
        CastManager.shared.playSelectedItemRemotely(to: durationCurrent) { (done) in
            if !done {
                self.playbackState = .pause
                self.startPlayer(nil)
            }
        }
    }
    
    private func pauseCastPlay() {
        playbackState = .pauseCast
        CastManager.shared.pauseSelectedItemRemotely(to: nil) { (done) in
            if !done {
                self.playbackState = .pause
                self.startPlayer(nil)
            }
        }
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
        if playbackState == .pause || playbackState == .created {
            player?.play()
            playbackState = .play
        } else {
            player?.pause()
            playbackState = .playCast
            continueCastPlay()
        }
        
        changeToPauseButton()
    }

    // MARK: Pause Player
    
    @objc private func pausePlayer(_ sender: Any?) {
        if playbackState == .play {
            player?.pause()
            playbackState = .pause
        } else {
            player?.pause()
            playbackState = .pauseCast
            pauseCastPlay()
        }
        
        changeToPlayButton()
    }

}
