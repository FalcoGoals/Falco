//
//  AssignedUsersTableView.swift
//  Falco
//
//  Created by Lim Kiat on 16/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class AssignedUsersTableView: UITableViewCell {
    private var assignedUsers: [User]?
    private var checkedUsers = [User: Bool]()
    
    func setUpUsers(goal: GroupGoal) {
        assignedUsers = goal.usersAssigned
        
        for assignedUser in assignedUsers! {
            checkedUsers[assignedUser] = goal.isCompletedByUser(assignedUser)
        }
    }
}

extension AssignedUsersTableView: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? AssignedUserTableViewCell
        if !checkedUsers[(cell?.user!)!]! {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            checkedUsers[(cell?.user!)!] = true
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.None
            checkedUsers[(cell?.user!)!] = false
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension AssignedUsersTableView: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (assignedUsers?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("userCell",
                                                               forIndexPath: indexPath) as? AssignedUserTableViewCell
        if cell == nil {
            cell = AssignedUserTableViewCell()
        }
        cell!.separatorInset = UIEdgeInsetsZero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.layoutMargins = UIEdgeInsetsZero
        let selectedUser = assignedUsers![indexPath.row]
        
        cell!.setUser(selectedUser)
        
        if checkedUsers[selectedUser]! {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell!
    }
}