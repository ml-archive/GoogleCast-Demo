//
//  ViewController.swift
//  NodesCast
//
//  Created by Andrei Hogea on 14/03/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var playerView: Player!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "NodesCast"
        createPlayerView()
    }

    private func createPlayerView() {
        let width = view.frame.width
        let height = width * 0.5625
        playerView = Player(frame: CGRect(x: 0, y: 0, width: width, height: height))
        view.addSubview(playerView)
    }
}

