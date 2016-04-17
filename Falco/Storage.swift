//
//  Storage.swift
//  Falco
//
//  Created by John Yong on 11/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class Storage {
    static let instance = Storage()
    var isFriendListPopulated = false
    var personalGoals = GoalCollection()
    var groups: [String: Group] = [:]
    var user: User!
    var friends: [String: User] = [:]
    var dataFilePath = ""
    var usersFilePath = ""
    private init() {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        if (paths.count > 0) {
            let documentDirectory: AnyObject = paths[0]
            usersFilePath = documentDirectory.stringByAppendingPathComponent("users.plist")
        }
        if let usersData = NSDictionary(contentsOfFile: usersFilePath) as? [String: AnyObject] {
            let userData = usersData["user"] as! [String: AnyObject]
            user = User(userData: userData)

            let friendsData = usersData["friends"] as! [String: [String: AnyObject]]
            for (friendId, friendData) in friendsData {
                friends[friendId] = User(userData: friendData)
            }
        }
    }
    func saveUsersData() {
        let dictionary = NSMutableDictionary()
        var usersDict: [String: AnyObject] = [:]
        usersDict["user"] = user.serialisedData
        var friendsData: [String: AnyObject] = [:]
        for friend in friends.values {
            friendsData[friend.id] = friend.serialisedData
        }
        usersDict["friends"] = friendsData
        dictionary.setDictionary(usersDict)
        dictionary.writeToFile(usersFilePath, atomically: true)
    }
    func loadFromCache() {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        if (paths.count > 0) {
            let documentDirectory: AnyObject = paths[0]
            dataFilePath = documentDirectory.stringByAppendingPathComponent("data.plist")
        }
        if let dictionary = NSDictionary(contentsOfFile: dataFilePath) as? [String: AnyObject] {
            let groupsData = dictionary["groups"] as! [String: [String: AnyObject]]
            for (groupId, groupData) in groupsData {
                groups[groupId] = Group(id: groupId, groupData: groupData)
            }

            let personalGoalsData = dictionary["personalGoals"] as! [String: AnyObject]
            personalGoals = GoalCollection(goalsData: personalGoalsData)
        }
    }
    func writeToCache() {
        let dictionary = NSMutableDictionary()
        var dataDict: [String: AnyObject] = [:]
        dataDict["personalGoals"] = personalGoals.serialisedData
        var groupsData: [String: [String: AnyObject]] = [:]
        for group in groups.values {
            groupsData[group.id] = group.serialisedData
        }
        dataDict["groups"] = groupsData
        dictionary.setDictionary(dataDict)
        dictionary.writeToFile(dataFilePath, atomically: true)
    }
    func getKnownUser(userId: String) -> User? {
        if userId == user.id {
            return user
        } else if let friend = friends[userId] {
            return friend
        } else {
            return nil
        }
    }
}