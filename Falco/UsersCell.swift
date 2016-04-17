//
//  AssignedUsersTableView.swift
//  Falco
//
//  Created by Lim Kiat on 16/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class UsersCell: UITableViewCell {
    private var assignedUsers: [User]?
    private var checkedUsers = [User: Bool]()
    
    func setUpUsers(goal: GroupGoal) {
        assignedUsers = goal.usersAssigned
        
        for assignedUser in assignedUsers! {
            checkedUsers[assignedUser] = goal.isCompletedByUser(assignedUser)
        }
    }
}

extension UsersCell: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserCell
        if !checkedUsers[cell.user]! {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            checkedUsers[cell.user] = true
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
            checkedUsers[cell.user] = false
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension UsersCell: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (assignedUsers?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell",
                                                               forIndexPath: indexPath) as! UserCell

        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        let selectedUser = assignedUsers![indexPath.row]
        
        cell.setUser(selectedUser)
        
        if checkedUsers[selectedUser]! {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
}