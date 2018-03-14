//
//  TimeInterval+String.swift
//  NodesCast
//
//  Created by Andrei Hogea on 14/03/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//

import UIKit

extension TimeInterval {
    func toTimeString() -> NSString {
        let ti = NSInteger(self)
        
        let seconds = ti % 60
        let minutes = ti / 60
        
        return NSString(format: "%0.1d:%0.2d", minutes, seconds)
    }
}

extension Int {
    func toTimeString() -> String {
        let ti = NSInteger(self)
        
        let seconds = ti % 60
        let minutes = ti / 60
        
        return NSString(format: "%0.1d:%0.2d", minutes, seconds) as String
    }
}

