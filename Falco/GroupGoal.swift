//
//  GroupGoal.swift
//  Falco
//
//  Created by Jing Yin Ong on 24/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class GroupGoal: Goal {
    private var _assignedUsers: [User: (Bool, NSDate?)]

    var assignedUsers: [User] { return Array(_assignedUsers.keys) }

    init(id: String, name: String, details: String, endTime: NSDate, priority: PriorityType = .Low) {
        _assignedUsers = [User: (Bool, NSDate?)]()
        super.init(id: id, name: name, details: details, endTime: endTime, priority: priority, goalType: .Group)
    }

    /// Assigns the input user to the goal
    func addUser(user: User) {  //check if is group goal
        _assignedUsers[user] = (false, nil)
    }

    /// Unassign the input user from the goal
    func removeUser(user: User) {
        _assignedUsers.removeValueForKey(user)
    }

    /// Unassigns all users from the goal
    func removeAllUsers() {
        _assignedUsers.removeAll()
    }

    /// Checks whether the goal has been assigned to the input user
    func userIsAssigned(user: User) -> Bool {
        return _assignedUsers.keys.contains(user)
    }

    /// Marks a particular user as having completed the goal
    /// Date which param user completed the task will be stored
    /// Returns indicator whether operation was successful
    func completedByUser(user: User) -> Bool {
        if userIsAssigned(user) {
            _assignedUsers[user] = (true, NSDate())
            return true
        }
        return false
    }

    /// Marks a particular user as not having completed the goal
    /// Returns indicator whether operation was successful
    func uncompleteByUser(user: User) -> Bool {
        if userIsAssigned(user) {
            _assignedUsers[user] = (false, nil)
            return true
        }
        return false
    }

    /// Returns whether a particular user has completed the goal
    func isCompletedByUser(user: User) -> Bool {
        if !userIsAssigned(user) {
            return false
        }
        return _assignedUsers[user]!.0
    }

    /// Returns the date which the last person completed the goal
    /// and nil if the goal was not completed
    func getCompletedDate() -> NSDate? {
        var latestDate: NSDate? = nil
        for value in _assignedUsers.values {
            if !value.0 {
                return nil
            }
            if latestDate != nil {
                latestDate = latestDate!.laterDate(value.1!)
            } else {
                latestDate = value.1
            }
        }
        return latestDate
    }

    /// Returns true if all assigned users completed the task, false otherwise
    func isCompleted() -> Bool {
        for value in _assignedUsers.values {
            if !value.0 {
                return false
            }
        }
        return true
    }

    /// Returns list of users who have completed the goal
    func getUsersWhoCompleted() -> [User] {
        var completedUsers = [User]()
        for key in _assignedUsers.keys {
            if _assignedUsers[key]!.0 {
                completedUsers.append(key)
            }
        }
        return completedUsers
    }

    /// Returns the total number of users assigned to the goal
    func getNumberOfUsersAssigned() -> Int {
        return _assignedUsers.keys.count
    }
}