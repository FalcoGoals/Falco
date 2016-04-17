//
//  GroupAddViewController.swift
//  Falco
//
//  Created by Jing Yin Ong on 6/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

protocol GroupAddDelegate {
    func didAddGroup(group: Group)
}

class GroupAddViewController: UIViewController {
    var delegate: GroupAddDelegate!

    private var _groupName: String?
    private var _friends = [User]()
    private var _checkedRows = [User: Bool]()
    private var _searchedFriends = [User]()

    private let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if Storage.instance.isFriendListPopulated {
            _friends = Array(Storage.instance.friends.values)
            for friend in _friends {
                _checkedRows[friend] = false
            }
            tableView.reloadData()
        } else {
            refreshData()
        }
        tableView.dataSource = self
        tableView.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func viewDidAppear(animated: Bool) {
        refreshData()
    }

    func refreshData() {
        Server.instance.getFriends() { users in
            if let contacts = users {
                self._friends = contacts
                self.tableView.reloadData()
                for friend in contacts {
                    self._checkedRows[friend] = false
                }
            }
        }
    }

    /// Displays cells of friends whose names match with the search text
    private func filterContentForSearchText(searchText: String, scope: String = Constants.groupSearchScope) {
        _searchedFriends = _friends.filter { friend in
            return friend.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    /// Creates a group. Checks and alerts for missing inputs
    @IBAction func createGroup(sender: AnyObject) {
        _groupName = nameInput.text
        var groupMembers = [User]()
        for friend in _checkedRows.keys {
            if _checkedRows[friend]! {
                groupMembers.append(friend)
            }
        }
        if _groupName == nil || _groupName == Constants.emptyString {
            let alert = UIAlertController(title: Constants.groupCreationFailMsg, message: Constants.nameReqMsg,
                                          preferredStyle: .Alert)
            warn(alert)
        } else if groupMembers.isEmpty {
            let alert = UIAlertController(title: Constants.groupCreationFailMsg, message: Constants.membersReqMsg,
                                          preferredStyle: .Alert)
            warn(alert)
        } else {
            let group = Group(creator: Storage.instance.user, name: _groupName!, members: groupMembers)
            delegate.didAddGroup(group)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    /// Does pop up for warning alerts for missing input
    private func warn(alert: UIAlertController) {
        searchController.active = false
        let okayAction = UIAlertAction(title: Constants.okayMessage, style: .Default) {
            (action: UIAlertAction) -> Void in
        }
        alert.addAction(okayAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}

extension GroupAddViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? FriendTableViewCell
        if !_checkedRows[(cell?.user!)!]! {//cell?.accessoryType == UITableViewCellAccessoryType.None {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            _checkedRows[(cell?.user!)!] = true
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.None
            _checkedRows[(cell?.user!)!] = false
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension GroupAddViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != Constants.emptyString {
            return _searchedFriends.count
        }
        return _friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(Constants.friendCellID,
                                                               forIndexPath: indexPath) as? FriendTableViewCell
        if cell == nil {
            cell = FriendTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: Constants.friendCellID)
        }
        cell!.separatorInset = UIEdgeInsetsZero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.layoutMargins = UIEdgeInsetsZero
        let selectedFriend: User
        
        if searchController.active && searchController.searchBar.text != Constants.emptyString {
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
}

extension GroupAddViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}