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
    let searchController = UISearchController(searchResultsController: nil)

    private var _groupName: String?
    private var _friends = [User]()
    private var _checkedRows = [User: Bool]()
    private var _searchedFriends = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        Server.instance.getFriends() { users in
            if let contacts = users {
                self._friends.appendContentsOf(contacts)
                self.tableView.reloadData()
                for friend in contacts {
                    self._checkedRows[friend] = false
                }
            }
        }
        tableView.dataSource = self
        tableView.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        _searchedFriends = _friends.filter { friend in
            return friend.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    /// Creates a group. Checks for missing inputs
    @IBAction func createGroup(sender: AnyObject) {
        _groupName = nameInput.text
        var groupMembers = [User]()
        for friend in _checkedRows.keys {
            if _checkedRows[friend]! {
                groupMembers.append(friend)
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
            Server.instance.saveGroup(group)
            print(group)
        }
    }
    
    /// Does pop up for warning alerts for missing input
    private func warn(alert: UIAlertController) {
        searchController.active = false
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
        if searchController.active && searchController.searchBar.text != "" {
            return _searchedFriends.count
        }
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
        let selectedFriend: User
        if searchController.active && searchController.searchBar.text != "" {
            selectedFriend = _searchedFriends[indexPath.row]
        } else {
            selectedFriend = _friends[indexPath.row]
        }
        cell!.setUser(selectedFriend)
        if _checkedRows[selectedFriend]! {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell!
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? FriendTableViewCell
        if !_checkedRows[(cell?.user!)!]! {//cell?.accessoryType == UITableViewCellAccessoryType.None {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            _checkedRows[(cell?.user!)!] = true
            
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.None
            _checkedRows[(cell?.user!)!] = false
        }
    }
}

extension GroupAddViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}