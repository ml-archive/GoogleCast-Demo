//
//  CastManager.swift
//  NodesCast
//
//  Created by Andrei Hogea on 14/03/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//

import Foundation
import GoogleCast

enum CastSessionStatus {
    case started
    case resumed
    case ended
    case failedToStart
    case alreadyConnected
}

class CastManager: NSObject {
    
    static let shared = CastManager()
    
    private var sessionManager: GCKSessionManager!
    var hasConnectionEstablished: Bool {
        let castSession = sessionManager.currentCastSession
        if castSession != nil {
            return true
        } else {
            return false
        }
    }
    
    private var sessionStatusListener: ((CastSessionStatus) -> Void)?
    private var sessionStatus: CastSessionStatus! {
        didSet {
            sessionStatusListener?(sessionStatus)
        }
    }
    
    // MARK: - Init
    
    func initialise() {
        initialiseContext()
        createSessionManager()
        style()
        miniControllerStyle()
        styleConnectionController()
    }
    
    private func createSessionManager() {
        sessionManager = GCKCastContext.sharedInstance().sessionManager
        sessionManager.add(self)
    }
    
    private func initialiseContext() {
        //application Id registered
        let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria.init(applicationID: "EC926046"))
        options.disableDiscoveryAutostart = false
        GCKCastContext.setSharedInstanceWith(options)
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
    }
    
    func addSessionStatusListener(listener: @escaping (CastSessionStatus) -> Void) {
        self.sessionStatusListener = listener
    }
    
    private func style() {
        let castStyle = GCKUIStyle.sharedInstance()
        castStyle.castViews.backgroundColor = .white
        castStyle.castViews.bodyTextColor = .nodesColor
        castStyle.castViews.buttonTextColor = .white
        castStyle.castViews.headingTextColor = .nodesColor
        castStyle.castViews.captionTextColor = .nodesColor
        castStyle.castViews.iconTintColor = .nodesColor
    
        castStyle.apply()
    }
    
    private func styleConnectionController() {
        let castStyle = GCKUIStyle.sharedInstance()
        //castStyle.castViews.deviceControl.connectionController.buttonTextColor = .nodesColor
        castStyle.apply()
    }
    
    private func miniControllerStyle() {
        let castStyle = GCKUIStyle.sharedInstance()
        castStyle.castViews.mediaControl.miniController.backgroundColor = .nodesColor
        castStyle.castViews.mediaControl.miniController.bodyTextColor = .white
        castStyle.castViews.mediaControl.miniController.buttonTextColor = .white
        castStyle.castViews.mediaControl.miniController.headingTextColor = .white
        castStyle.castViews.mediaControl.miniController.captionTextColor = .white
        castStyle.castViews.mediaControl.miniController.iconTintColor = .white
        
        castStyle.apply()
    }
    
    // MARK: - Build Meta
    
    func buildMediaInformation(with title: String, with description: String, with studio: String, with duration: TimeInterval, with movieUrl: String, with streamType: GCKMediaStreamType, with thumbnailUrl: String?) -> GCKMediaInformation {
        let metadata = buildMetadata(with: title, with: description, with: studio, with: thumbnailUrl)
        
        let mediaInfo = GCKMediaInformation.init(contentID: movieUrl, streamType: streamType, contentType: "video/m3u8", metadata: metadata, streamDuration: duration, mediaTracks: nil, textTrackStyle: nil, customData: nil)
        
        return mediaInfo
    }
    
    private func buildMetadata(with title: String, with description: String, with studio: String, with thumbnailUrl: String?) -> GCKMediaMetadata {
        let metadata = GCKMediaMetadata.init(metadataType: .movie)
        metadata.setString(title, forKey: kGCKMetadataKeyTitle)
        metadata.setString(description, forKey: "description")
        let deviceName = sessionManager.currentCastSession?.device.friendlyName ?? studio
        metadata.setString(deviceName, forKey: kGCKMetadataKeyStudio)
        
        if let thumbnailUrl = thumbnailUrl, let url = URL(string: thumbnailUrl) {
            metadata.addImage(GCKImage.init(url: url, width: 720, height: 480))
        }
        
        return metadata
    }
    
    // MARK: - Start
    
    func startSelectedItemRemotely(_ mediaInfo: GCKMediaInformation, at time: TimeInterval, completion: (Bool) -> Void) {
        let castSession = sessionManager.currentCastSession
        
        if castSession != nil {
            let options = GCKMediaLoadOptions()
            options.playPosition = time
            castSession?.remoteMediaClient?.loadMedia(mediaInfo, with: options)
            completion(true)
            
            sessionStatus = .alreadyConnected
        } else {
            completion(false)
        }
    }
    
    // MARK: - Play/Resume
    
    func playSelectedItemRemotely(to time: TimeInterval?, completion: (Bool) -> Void) {
        let castSession = sessionManager.currentCastSession
        if castSession != nil {
            let remoteClient = castSession?.remoteMediaClient
            if let time = time {
                let options = GCKMediaSeekOptions()
                options.interval = time
                options.resumeState = .play
                remoteClient?.seek(with: options)
            } else {
                remoteClient?.play()
            }
            completion(true)
        } else {
            completion(false)
        }
    }
    
    // MARK: - Pause
    
    func pauseSelectedItemRemotely(to time: TimeInterval?, completion: (Bool) -> Void) {
        let castSession = sessionManager.currentCastSession
        if castSession != nil {
            let remoteClient = castSession?.remoteMediaClient
            if let time = time {
                let options = GCKMediaSeekOptions()
                options.interval = time
                options.resumeState = .pause
                remoteClient?.seek(with: options)
            } else {
                remoteClient?.pause()
            }
            completion(true)
        } else {
            completion(false)
        }
    }
    
    // MARK: - Update Current Time
    
    func getSessionCurrentTime(completion: (TimeInterval?) -> Void) {
        let castSession = sessionManager.currentCastSession
        if castSession != nil {
            let remoteClient = castSession?.remoteMediaClient
            let currentTime = remoteClient?.approximateStreamPosition()
            completion(currentTime)
        } else {
            completion(nil)
        }
    }
    
    // MARK: - Buffering status
    
    func getMediaPlayerState(completion: (GCKMediaPlayerState) -> Void) {
        if let castSession = sessionManager.currentCastSession,
            let remoteClient = castSession.remoteMediaClient,
            let mediaStatus = remoteClient.mediaStatus {
            completion(mediaStatus.playerState)
        }
        
        completion(GCKMediaPlayerState.unknown)
    }
}

// MARK: - GCKSessionManagerListener

extension CastManager: GCKSessionManagerListener {
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        sessionStatus = .started
    }
    
    public func sessionManager(_ sessionManager: GCKSessionManager, didResumeSession session: GCKSession) {
        sessionStatus = .resumed
    }
    
    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        sessionStatus = .ended
    }
    
    public func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
        sessionStatus = .failedToStart
    }
    
    public func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKSession, with reason: GCKConnectionSuspendReason) {
        sessionStatus = .ended
    }
}
