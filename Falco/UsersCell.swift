//
//  AssignedUsersTableView.swift
//  Falco
//
//  Created by Lim Kiat on 16/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class UsersCell: UITableViewCell {
    private var allGroupMembers: [User]!
    private var isUserAssigned = [User: Bool]()
    
    func initUsers(goal: GroupGoal, groupMembers: [User]) {
        allGroupMembers = groupMembers

        for groupMember in groupMembers {
            isUserAssigned[groupMember] = goal.isUserAssigned(groupMember)
        }
    }
}

extension UsersCell: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserCell
        if !isUserAssigned[cell.user]! {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            isUserAssigned[cell.user] = true
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
            isUserAssigned[cell.user] = false
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension UsersCell: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isUserAssigned.keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell",
                                                               forIndexPath: indexPath) as! UserCell

        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        let selectedUser = allGroupMembers[indexPath.row]
        
        cell.setUser(selectedUser)
        
        if isUserAssigned[selectedUser]! {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
}