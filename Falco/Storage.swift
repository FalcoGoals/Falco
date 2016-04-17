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
    var friends: [String: User] = [:]
    private init() {}
    func getKnownUser(userId: String) -> User? {
        if userId == Server.instance.user.id {
            return Server.instance.user
        } else if let friend = friends[userId] {
            return friend
        } else {
            return nil
        }
    }
}