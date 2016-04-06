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
    @IBOutlet var tableView: UITableView!
    
    private var groupName: String?
    private var friends = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Server.instance.getFriends() { users in
            if let contacts = users {
                self.friends.appendContentsOf(contacts)
                self.tableView.reloadData()
            }
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func createGroup(sender: AnyObject) {
        if let name = nameInput.text {
            groupName = name
            
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as? FriendTableViewCell
        if cell == nil {
            cell = FriendTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "friendCell")
        }
        cell!.separatorInset = UIEdgeInsetsZero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.layoutMargins = UIEdgeInsetsZero
        cell!.friendNameLabel?.text = friends[indexPath.row].name
        let url = NSURL(string: friends[indexPath.row].pictureUrl)
        cell!.friendImageView?.image = UIImage(data: NSData(contentsOfURL: url!)!)

        //cell.friendImageView =
        return cell!
    }
    
}