//
//  FirstViewController.swift
//  NodesCast
//
//  Created by Andrei Hogea on 14/03/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//


import UIKit
import GoogleCast

class FirstViewController: UIViewController, Castable {
    
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
                
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "NodesCast"
        createContainer()
        createMiniMediaControl()
        
        addCastButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if mediaControlsContainerView != nil {
            updateControlBarsVisibility()
        }
    }
    
    // MARK: - Cast Button
    
    private func addCastButton() {
        castButton = googleCastBarButton
        navigationItem.rightBarButtonItems = [castButton]
    }
    
    // MARK: - GCKUIMiniMediaControlsViewController
    
    private func createContainer() {
        mediaControlsContainerView = UIView(frame: CGRect(x: 0, y: view.frame.maxY, width: view.frame.width, height: 0))
        mediaControlsContainerView.accessibilityIdentifier = "mediaControlsContainerView"
        view.addSubview(mediaControlsContainerView)
        mediaControlsContainerView.translatesAutoresizingMaskIntoConstraints = false
        mediaControlsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mediaControlsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mediaControlsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        miniMediaControlsHeightConstraint = mediaControlsContainerView.heightAnchor.constraint(equalToConstant: 0)
        miniMediaControlsHeightConstraint.isActive = true
    }
    
    private func createMiniMediaControl() {
        let castContext = GCKCastContext.sharedInstance()
        miniMediaControlsViewController = castContext.createMiniMediaControlsViewController()
        miniMediaControlsViewController.delegate = self
        mediaControlsContainerView.alpha = 0
        miniMediaControlsViewController.view.alpha = 0
        miniMediaControlsHeightConstraint.constant = miniMediaControlsViewController.minHeight
        installViewController(miniMediaControlsViewController, inContainerView: mediaControlsContainerView)
        
        updateControlBarsVisibility()
    }
    
    private func updateControlBarsVisibility() {
        if miniMediaControlsViewController.active {
            miniMediaControlsHeightConstraint.constant = miniMediaControlsViewController.minHeight
            view.bringSubview(toFront: mediaControlsContainerView)
        } else {
            miniMediaControlsHeightConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in //swiftlint:disable:this multiple_closures_with_trailing_closure
            self.mediaControlsContainerView.alpha = 1
            self.miniMediaControlsViewController.view.alpha = 1
        }
    }
    
    private func installViewController(_ viewController: UIViewController?, inContainerView containerView: UIView) {
        if let viewController = viewController {
            viewController.view.isHidden = true
            addChildViewController(viewController)
            viewController.view.frame = containerView.bounds
            containerView.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
            viewController.view.isHidden = false
        }
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

// MARK: - GCKUIMiniMediaControlsViewControllerDelegate

extension FirstViewController: GCKUIMiniMediaControlsViewControllerDelegate {
    func miniMediaControlsViewController(_ miniMediaControlsViewController: GCKUIMiniMediaControlsViewController, shouldAppear: Bool) {
        updateControlBarsVisibility()
    }
}

