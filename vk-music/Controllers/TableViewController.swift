//
//  TableViewController.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 12/7/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    lazy var playerBarButtonItem: UIBarButtonItem = {
        var button = UIButton.buttonWithType(.System) as! UIButton
        var image = UIImage(named: "IMNowPlayingForwardChevron")!
        button.frame = CGRect(x: 0, y: 0, width: 65, height: 44)
        button.setImage(image, forState: .Normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(image.size.width+15), bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: button.frame.size.width - image.size.width, bottom: 0, right: 0)
        button.setTitle("Player", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(16)
        button.addTarget(self, action: "showPlayerBarButtonTapped:", forControlEvents: .TouchUpInside)
        return UIBarButtonItem(customView: button)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.playerBarButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func showPlayerBarButtonTapped(sender: AnyObject) {
        self.navigationController?.pushViewController(PlayerViewController.sharedInstance(), animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

}
