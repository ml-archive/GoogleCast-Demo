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
    case createdCast
    case playCast
    case play
    case pauseCast
    case pause
    case finishedCast
    case finished
}

class Player: UIView {
    
    private let timeObserver = "currentItem.loadedTimeRanges"
    
    var mediaItem: MediaItem!
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var playbackState: PlaybackState = .created
    
    private var playPauseButton: UIButton!
    private var spinner: UIActivityIndicatorView!

    //bottom controls
    private var buttonStackView: UIStackView!
    private var currentTimeLabel: UILabel!
    private var totalTimeLabel: UILabel!
    private var slider: UISlider!
    
    //timers
    private var localTimer: Timer?
    private var castTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        player.removeObserver(self, forKeyPath: timeObserver)
    }
    
    func initPlayerLayer() {
        guard let url = URL(string: mediaItem.videoUrl) else { return }
        
        player = AVPlayer(url: url)
        player.addObserver(self, forKeyPath: timeObserver, options: .new, context: nil)
        playerLayer = AVPlayerLayer(player: player)
        layer.addSublayer(playerLayer)
        playerLayer.frame = bounds
        createSpinner()
    }
    
    private func createSpinner() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.hidesWhenStopped = true
        spinner.stopAnimating()
        addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 40).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: 40).isActive = true
        spinner.startAnimating()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayer && keyPath == timeObserver {
            let loadedTimeRanges = player.currentItem?.loadedTimeRanges
            guard let timeRanges = loadedTimeRanges, timeRanges.count > 0, let timeRange = timeRanges[0] as? CMTimeRange else { return }
            let currentBufferDuration = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
            if player.status == AVPlayerStatus.readyToPlay && currentBufferDuration > 2 {
                createPlayPauseButton()
                createButtonStackView()
                spinner.stopAnimating()
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

    // MARK: - Bottom Controls
    
    // MARK: Button StackView
    
    private func createButtonStackView() {
        buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.spacing = 5
        addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        createcurrentTimeLabel()
        createSlider()
        createTotalTimeLabel()
    }
    
    // MARK: - Current Time Gradient Label
    
    private func createcurrentTimeLabel() {
        currentTimeLabel = UILabel()
        currentTimeLabel.textAlignment = .right
        currentTimeLabel.textColor = .white
        buttonStackView.addArrangedSubview(currentTimeLabel)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // MARK: - Total Time Gradient Label
    
    private func createTotalTimeLabel() {
        totalTimeLabel = UILabel()
        totalTimeLabel.textAlignment = .left
        totalTimeLabel.textColor = .white
        buttonStackView.addArrangedSubview(totalTimeLabel)
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // MARK: - Player Slider
    
    private func createSlider() {
        slider = UISlider()
        slider.isContinuous = true
        slider.isUserInteractionEnabled = true
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.tintColor = UIColor.nodesColor
        slider.value = 0
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        addSliderRecognizers()
        buttonStackView.addArrangedSubview(slider)
    }
    
    // MARK: - Update slider on Local
    
    private func scheduleLocalTimer() {
        DispatchQueue.main.async {
            switch self.playbackState {
            case .play, .pause, .created:
                self.castTimer?.invalidate()
                self.castTimer = nil
                self.localTimer?.invalidate()
                self.localTimer = Timer.scheduledTimer(timeInterval: 1,
                                                          target: self,
                                                          selector: #selector(self.updateInfoContent),
                                                          userInfo: nil,
                                                          repeats: true)
            default:
                self.localTimer?.invalidate()
                self.localTimer = nil
            }
        }
    }
    
    @objc private func updateInfoContent() {
        guard let currentItem = player.currentItem else { return }
        let currentTime = player.currentTime().seconds
        let duration = currentItem.asset.duration.seconds
        slider.value = Float(currentTime / duration)
        
        totalTimeLabel.text = duration.toTimeString() as String
        currentTimeLabel.text = currentTime.toTimeString() as String
        
    }

    // MARK: - Player Slider Actions
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        guard let currentItem = player.currentItem else { return }
        let duration = currentItem.asset.duration.seconds
        
        let timeToSeek = duration * Double(sender.value)
        
        player.seek(to: CMTime.init(seconds: timeToSeek, preferredTimescale: CMTimeScale.max))
    }
    
    private func addSliderRecognizers() {
        let tapSlider = UITapGestureRecognizer(target: self, action: #selector(tapSlider(_:)))
        slider.addGestureRecognizer(tapSlider)
    }
    
    @objc private func tapSlider(_ recognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = recognizer.location(in: self)

        let positionOfSlider: CGPoint = slider.frame.origin
        let widthOfSlider: CGFloat = slider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(slider.maximumValue) / widthOfSlider)

        slider.setValue(Float(newValue), animated: true)
        
        guard let currentItem = player.currentItem else { return }
        let duration = currentItem.asset.duration.seconds
        let timeToSeek = duration * Double(slider.value)
        player.seek(to: CMTime.init(seconds: timeToSeek, preferredTimescale: CMTimeScale.max))
    }
    
}
