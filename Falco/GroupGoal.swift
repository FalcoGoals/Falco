//
//  GroupGoal.swift
//  Falco
//
//  Created by Jing Yin Ong on 24/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class GroupGoal: Goal {
    private var _assignedUsers: [User: Tuple]

    var assignedUsers: [User] { return Array(_assignedUsers.keys) }

    init(uid: String, name: String, details: String, endTime: NSDate, priority: PriorityType = .Low, data: [User: Tuple] = [:]) {
        _assignedUsers = data
        super.init(uid: uid, name: name, details: details, endTime: endTime, priority: priority, goalType: GoalType.Group)
    }
    
    /// Assigns the input user to the goal
    func addUser(user: User) {  //check if is group goal
        _assignedUsers[user] = Tuple(isCompleted: false, completedDate: nil)
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
            _assignedUsers[user] = Tuple(isCompleted: true, completedDate: NSDate())
            return true
        }
        return false
    }

    /// Marks a particular user as not having completed the goal
    /// Returns indicator whether operation was successful
    func uncompleteByUser(user: User) -> Bool {
        if userIsAssigned(user) {
            _assignedUsers[user] = Tuple(isCompleted: false, completedDate: nil)
            return true
        }
        return false
    }

    /// Returns whether a particular user has completed the goal
    func isCompletedByUser(user: User) -> Bool {
        if !userIsAssigned(user) {
            return false
        }
        return _assignedUsers[user]!.isCompleted
    }

    /// Returns the date which the last person completed the goal
    /// and nil if the goal was not completed
    func getCompletedDate() -> NSDate? {
        var latestDate: NSDate? = nil
        for value in _assignedUsers.values {
            if !value.isCompleted {
                return nil
            }
            if latestDate != nil {
                latestDate = latestDate!.laterDate(value.completedDate!)
            } else {
                latestDate = value.completedDate
            }
        }
        return latestDate
    }

    /// Returns true if all assigned users completed the task, false otherwise
    func isCompleted() -> Bool {
        for value in _assignedUsers.values {
            if !value.isCompleted {
                return false
            }
        }
        return true
    }

    /// Returns list of users who have completed the goal
    func getUsersWhoCompleted() -> [User] {
        var completedUsers = [User]()
        for key in _assignedUsers.keys {
            if _assignedUsers[key]!.isCompleted {
                completedUsers.append(key)
            }
        }
        return completedUsers
    }

    /// Returns the total number of users assigned to the goal
    func getNumberOfUsersAssigned() -> Int {
        return _assignedUsers.keys.count
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeObject(_assignedUsers, forKey: Constants.groupGoalDataKey)
    }
    
    required convenience init(coder decoder: NSCoder) {
        let uid = decoder.decodeObjectForKey(Constants.uidKey) as! String
        let name = decoder.decodeObjectForKey(Constants.nameKey) as! String
        let details = decoder.decodeObjectForKey(Constants.detailsKey) as! String
        let endTime = decoder.decodeObjectForKey(Constants.endTimeKey) as! NSDate
        let priority = PriorityType(rawValue: decoder.decodeIntegerForKey(Constants.priorityKey))
        let data = decoder.decodeObjectForKey(Constants.groupGoalDataKey) as! [User: Tuple]
        self.init(uid: uid, name: name, details: details, endTime: endTime, priority: priority!, data: data)
    }
    
    /// Inner class used as value type in GroupGoal's dictionary variable to indicate whether a user
    /// has completed the goal and if so, the date which he/she did so
    class Tuple: NSObject, NSCoding {
        private var _isCompleted: Bool
        private var _completedDate: NSDate?
        var isCompleted: Bool { return _isCompleted }
        var completedDate: NSDate? { return _completedDate }
        init(isCompleted: Bool, completedDate: NSDate?) {
            _isCompleted = isCompleted
            _completedDate = completedDate
        }
        
        @objc func encodeWithCoder(coder: NSCoder) {
            coder.encodeBool(_isCompleted, forKey: Constants.isCompletedKey)
            coder.encodeObject(_completedDate, forKey: Constants.timeOfCompletionKey)
        }
        
        @objc required convenience init(coder decoder: NSCoder) {
            let isCompleted = decoder.decodeBoolForKey(Constants.isCompletedKey)
            let completedDate = decoder.decodeObjectForKey(Constants.timeOfCompletionKey) as! NSDate?
            self.init(isCompleted: isCompleted, completedDate: completedDate)
        }
    }
}