//
//  GroupAddViewController.swift
//  Falco
//
//  Created by Jing Yin Ong on 6/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation
import UIKit

class GroupAddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var nameInput: UITextField!
    
    private var groupName: String?
    private var friends = [User]()//Server.instance.getFriends()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createGroup(sender: AnyObject) {
        if let name = nameInput.text {
            groupName = name
            
        } // else say no
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell") as! FriendTableViewCell
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        cell.friendNameLabel.text = friends[indexPath.row].name
        //cell.friendImageView =
        return cell
    }
    
}