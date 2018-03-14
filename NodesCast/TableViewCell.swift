//
//  TableViewCell.swift
//  NodesCast
//
//  Created by Andrei Hogea on 14/03/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.textColor = UIColor(red: 255 / 255, green: 77 / 255, blue: 121 / 255, alpha: 1)
        }
    }
}
