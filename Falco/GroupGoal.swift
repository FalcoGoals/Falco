//
//  GroupGoal.swift
//  Falco
//
//  Created by Jing Yin Ong on 24/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

/**
 Overview: Struct representing a group goal, which involves multiple user
 SpecFields:
 _id (String):                      Is unique, goals are referenced by this id
 _groupId (String):                 Stores a reference id to the group the goal belongs to
 _userCompletionTimes (Dictionary): The date in which each user completed the goal [User: NSDate]
 name (String):                     Stores the name of the goal object
 details (String):                  Stores the details of the goal object
 priority (Double):                 A numerical value representing the priority of the goal object
 endTime (NSDate):                  Stores the goal's deadline
 */
struct GroupGoal: Goal {
    private let _id: String
    private let _groupId: String
    private var _userCompletionTimes: [User: NSDate]

    // MARK: Properties

    var name: String
    var details: String
    var priority: Double
    var endTime: NSDate

    var id: String { return _id }
    var groupId: String { return _groupId }
    var completionTime: NSDate {
        if usersCompletedCount < usersAssignedCount {
            return Constants.incompleteTimeValue
        }

        var latestCompletionTime = NSDate.distantPast()
        for (_, userCompletionTime) in _userCompletionTimes {
            if latestCompletionTime.compare(userCompletionTime) == .OrderedAscending {
                latestCompletionTime = userCompletionTime
            }
        }
        return latestCompletionTime
    }
    var userCompletionTimes: [User: NSDate] { return _userCompletionTimes }
    var usersAssigned: [User] { return Array(_userCompletionTimes.keys) }
    var usersAssignedCount: Int { return _userCompletionTimes.keys.count }
    var usersCompleted: [User] {
        var completedUsers = [User]()
        for user in _userCompletionTimes.keys {
            if _userCompletionTimes[user] != Constants.incompleteTimeValue {
                completedUsers.append(user)
            }
        }
        return completedUsers
    }
    var usersCompletedCount: Int { return usersCompleted.count }

    var serialisedData: [String: AnyObject] {
        var serialisedUserData: [String: NSNumber] = [:]
        for (user, userCompletionTime) in userCompletionTimes {
            serialisedUserData[user.id] = userCompletionTime.timeIntervalSince1970
        }
        let goalData: [String: AnyObject] = [Constants.nameKey: name,
                                             Constants.detailsKey: details,
                                             Constants.priorityKey: priority,
                                             Constants.endTimeKey: endTime.timeIntervalSince1970,
                                             Constants.userCompletionTimesKey: serialisedUserData]
        return goalData
    }

    // MARK: Init

    init(id: String = NSUUID().UUIDString, groupId: String, name: String, details: String, priority: Double = 0, endTime: NSDate, userCompletionTimes: [User: NSDate] = [:]) {
        self._id = id
        self._groupId = groupId
        self.name = name
        self.details = details
        self.priority = priority
        self.endTime = endTime
        self._userCompletionTimes = userCompletionTimes
    }

    init(id: String, groupId: String, goalData: [String: AnyObject]) {
        let name = goalData[Constants.nameKey]! as! String
        let details = goalData[Constants.detailsKey]! as! String
        let priority = goalData[Constants.priorityKey]! as! Double
        let endTime = NSDate(timeIntervalSince1970: NSTimeInterval(goalData[Constants.endTimeKey] as! NSNumber))
        let userData = goalData[Constants.userCompletionTimesKey]! as! [String: NSNumber]
        var userCompletionTimes: [User: NSDate] = [:]
        for (userId, userCompletionTime) in userData {
            let user: User
            if let knownUser = Storage.instance.getKnownUser(userId) {
                user = knownUser
            } else {
                user = User(id: userId)
            }
            let completionTime = NSDate(timeIntervalSince1970: NSTimeInterval(userCompletionTime))
            userCompletionTimes[user] = completionTime
        }
        self.init(id: id, groupId: groupId, name: name, details: details, priority: priority, endTime: endTime, userCompletionTimes: userCompletionTimes)
    }

    // MARK: Methods (mutating)

    /// Assigns the input user to the goal
    mutating func addUser(user: User) {  //check if is group goal
        _userCompletionTimes[user] = Constants.incompleteTimeValue
    }

    /// Unassign the input user from the goal
    mutating func removeUser(user: User) {
        _userCompletionTimes.removeValueForKey(user)
    }

    /// Unassigns all users from the goal
    mutating func removeAllUsers() {
        _userCompletionTimes.removeAll()
    }

    /// Marks a particular user as having completed the goal
    /// Date which param user completed the task will be stored
    /// Returns indicator whether operation was successful
    mutating func markCompleteByUser(user: User) -> Bool {
        if isUserAssigned(user) {
            _userCompletionTimes[user] = NSDate()
            return true
        }
        return false
    }

    /// Marks a particular user as not having completed the goal
    /// Returns indicator whether operation was successful
    mutating func markIncompleteByUser(user: User) -> Bool {
        if isUserAssigned(user) {
            _userCompletionTimes[user] = Constants.incompleteTimeValue
            return true
        }
        return false
    }

    // MARK: Methods (non-mutating)

    /// Checks whether the goal has been assigned to the input user
    func isUserAssigned(user: User) -> Bool {
        return _userCompletionTimes.keys.contains(user)
    }

    /// Returns whether a particular user has completed the goal
    func isCompletedByUser(user: User) -> Bool {
        if !isUserAssigned(user) {
            return false
        }
        return _userCompletionTimes[user] != Constants.incompleteTimeValue
    }
}
