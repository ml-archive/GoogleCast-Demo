//
//  Style.swift
//  NodesCast
//
//  Created by Andrei Hogea on 14/03/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//

import UIKit

struct Style {
    static func setUp() {
        UINavigationBar.appearance().isTranslucent = false
        
        UINavigationBar.appearance().barTintColor = UIColor.nodesColor
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
    }
}
