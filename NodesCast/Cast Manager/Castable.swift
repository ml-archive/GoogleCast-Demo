//
//  Castable.swift
//  NodesCast
//
//  Created by Andrei Hogea on 14/03/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//

import UIKit
import GoogleCast

protocol Castable {
    var googleCastBarButton: UIBarButtonItem! { get }
}

extension Castable where Self:UIViewController {
    var googleCastBarButton: UIBarButtonItem! {
        let castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        castButton.tintColor = .white
        return UIBarButtonItem(customView: castButton)
    }
}
