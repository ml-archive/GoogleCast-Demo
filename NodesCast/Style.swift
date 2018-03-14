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
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 255 / 255, green: 77 / 255, blue: 121 / 255, alpha: 1)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
    }
}
