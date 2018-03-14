//
//  ViewController.swift
//  NodesCast
//
//  Created by Andrei Hogea on 14/03/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//

import UIKit
import GoogleCast

class PlayerViewController: UIViewController, Castable {
    
    var mediaItem: MediaItem!
    private var playerView: Player!
    private var castButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "NodesCast"

        createPlayerView()
        
        addCastButton()
    }

    // MARK: - Cast Button
    
    private func addCastButton() {
        castButton = googleCastBarButton
        navigationItem.rightBarButtonItems = [castButton]
    }
    
    // MARK: - Player

    private func createPlayerView() {
        let width = view.frame.width
        let height = width * 0.5625
        playerView = Player(frame: CGRect(x: 0, y: 0, width: width, height: height))
        playerView.mediaItem = mediaItem
        playerView.initPlayerLayer()
        view.addSubview(playerView)
    }

}

