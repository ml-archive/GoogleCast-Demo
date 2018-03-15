//
//  FirstViewController.swift
//  NodesCast
//
//  Created by Andrei Hogea on 14/03/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//


import UIKit
import GoogleCast

class FirstViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = .clear
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorColor = UIColor(red: 255 / 255, green: 77 / 255, blue: 121 / 255, alpha: 1)
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            tableView.rowHeight = 60
            tableView.register(UINib.init(nibName: "\(TableViewCell.self)", bundle: Bundle.main), forCellReuseIdentifier: "TableViewCell")
        }
    }
    private var castButton: UIBarButtonItem!
    
    private var data: [MediaItem] = [MediaItems.mediaItem1, MediaItems.mediaItem2, MediaItems.mediaItem3]
    
    private var mediaControlsContainerView: UIView!
    private var miniMediaControlsHeightConstraint: NSLayoutConstraint!
    private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                    
        title = "NodesCast"
    }
    
}

// MARK: - UITableViewDataSource

extension FirstViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let mediaItem = data[indexPath.row]
        cell.label.text = mediaItem.name
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension FirstViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let mediaItem = data[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        vc.mediaItem = mediaItem
        navigationController?.pushViewController(vc, animated: true)
    }
}
