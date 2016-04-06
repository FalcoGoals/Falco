//
//  GroupGoal.swift
//  Falco
//
//  Created by Jing Yin Ong on 24/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

struct GroupGoal: Goal {
    private let _id: String
    private var _userCompletionTimes: [User: NSDate]

    var name: String
    var details: String
    var priority: PriorityType
    var endTime: NSDate

    var id: String { return _id }
    var completionTime: NSDate {
        var latestCompletionTime = NSDate.distantPast()
        for (_, userCompletionTime) in _userCompletionTimes {
            if latestCompletionTime.compare(userCompletionTime) == .OrderedAscending {
                latestCompletionTime = userCompletionTime
            }
        }
        return latestCompletionTime
    }
    var assignedUsers: [User] { return Array(_userCompletionTimes.keys) }
    var userCompletionTimes: [User: NSDate] { return _userCompletionTimes }

    var serialisedData: [String: AnyObject] {
        var serialisedUserData: [String: NSNumber] = [:]
        for (user, userCompletionTime) in userCompletionTimes {
            serialisedUserData[user.id] = userCompletionTime.timeIntervalSince1970
        }
        let goalData: [String: AnyObject] = [Constants.nameKey: name,
                                             Constants.detailsKey: details,
                                             Constants.priorityKey: priority.rawValue,
                                             Constants.userCompletionTimesKey: serialisedUserData]
        return goalData
    }

    init(id: String = NSUUID().UUIDString, name: String, details: String, priority: PriorityType = .Low, endTime: NSDate, userCompletionTimes: [User: NSDate] = [:]) {
        self._id = id
        self.name = name
        self.details = details
        self.priority = priority
        self.endTime = endTime
        self._userCompletionTimes = userCompletionTimes
    }
    
    /// Assigns the input user to the goal
    mutating func addUser(user: User) {  //check if is group goal
        _userCompletionTimes[user] = NSDate.distantPast()
    }

    /// Unassign the input user from the goal
    mutating func removeUser(user: User) {
        _userCompletionTimes.removeValueForKey(user)
    }

    /// Unassigns all users from the goal
    mutating func removeAllUsers() {
        _userCompletionTimes.removeAll()
    }

    /// Checks whether the goal has been assigned to the input user
    func userIsAssigned(user: User) -> Bool {
        return _userCompletionTimes.keys.contains(user)
    }

    /// Marks a particular user as having completed the goal
    /// Date which param user completed the task will be stored
    /// Returns indicator whether operation was successful
    mutating func markCompleteByUser(user: User) -> Bool {
        if userIsAssigned(user) {
            _userCompletionTimes[user] = NSDate()
            return true
        }
        return false
    }

    /// Marks a particular user as not having completed the goal
    /// Returns indicator whether operation was successful
    mutating func markIncompleteByUser(user: User) -> Bool {
        if userIsAssigned(user) {
            _userCompletionTimes[user] = NSDate.distantPast()
            return true
        }
        return false
    }

    /// Returns whether a particular user has completed the goal
    func isCompletedByUser(user: User) -> Bool {
        if !userIsAssigned(user) {
            return false
        }
        return _userCompletionTimes[user] != nil
    }

    /// Returns list of users who have completed the goal
    func getUsersWhoCompleted() -> [User] {
        var completedUsers = [User]()
        for user in _userCompletionTimes.keys {
            if _userCompletionTimes[user] != nil {
                completedUsers.append(user)
            }
        }
        return completedUsers
    }

    /// Returns the total number of users assigned to the goal
    func getNumberOfUsersAssigned() -> Int {
        return _userCompletionTimes.keys.count
    }
}
