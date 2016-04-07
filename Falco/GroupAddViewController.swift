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
    
    private var _groupName: String?
    private var _friends = [User]()
    private var _checkedRows = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Server.instance.getFriends() { users in
            if let contacts = users {
                self._friends.appendContentsOf(contacts)
                self.tableView.reloadData()
                for _ in contacts {
                    self._checkedRows.append(false)
                }
            }
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    /// Creates a group. Checks for missing inputs
    @IBAction func createGroup(sender: AnyObject) {
        _groupName = nameInput.text
        var groupMembers = [User]()
        for i in 0..<_checkedRows.count {
            if _checkedRows[i] {
                groupMembers.append(_friends[i])
            }
        }
        if _groupName == nil || _groupName == "" {
            let alert = UIAlertController(title: "Failed to create group", message: "A group name is required", preferredStyle: .Alert)
            warn(alert)
        } else if groupMembers.isEmpty {
            let alert = UIAlertController(title: "Failed to create group", message: "Please select members to join the group", preferredStyle: .Alert)
            warn(alert)
        } else {
            let group = Group(name: _groupName!, members: groupMembers)
            print(group)
        }
    }
    
    /// Does pop up for warning alerts for missing input
    private func warn(alert: UIAlertController) {
        let okayAction = UIAlertAction(title: "Okay", style: .Default) {
            (action: UIAlertAction) -> Void in
        }
        alert.addAction(okayAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /// Tableview protocol requirements
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as? FriendTableViewCell
        if cell == nil {
            cell = FriendTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "friendCell")
        }
        cell!.separatorInset = UIEdgeInsetsZero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.layoutMargins = UIEdgeInsetsZero
        cell!.friendNameLabel?.text = _friends[indexPath.row].name
        let url = NSURL(string: _friends[indexPath.row].pictureUrl)
        cell!.friendImageView?.image = UIImage(data: NSData(contentsOfURL: url!)!)
        return cell!
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.accessoryType == UITableViewCellAccessoryType.None {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            _checkedRows[indexPath.row] = true
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.None
            _checkedRows[indexPath.row] = false
        }
    }
    
    
}