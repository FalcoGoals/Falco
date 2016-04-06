//
//  Group.swift
//  Falco
//
//  Created by Jing Yin Ong on 21/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class Group {
    private let _id: String
    private var _name: String
    private var _members: [User]
    private var _goals: GoalCollection

    var id: String { return _id }
    var name: String { return _name }
    var members: [User] { return _members }
    var goals: GoalCollection { return _goals }
    var serialisedData: [String: AnyObject] {
        var serialisedMemberData: [String: Bool] = [:]
        for member in members {
            serialisedMemberData[member.id] = true
        }
        let groupData: [String: AnyObject] = [Constants.nameKey: name,
                                              Constants.membersKey: serialisedMemberData,
                                              Constants.goalsKey: goals.serialisedData]
        return groupData
    }

    init(id: String = NSUUID().UUIDString, creator: User? = nil, name: String, members: [User], goals: GoalCollection = GoalCollection()) {
        _id = id
        _name = name
        if let creator = creator {
            _members = members + [creator]
        } else {
            _members = members
        }
        _goals = goals
    }

    func addMember(member: User) {
        _members.append(member)
    }

    func removeMember(member: User) {
        if (containsMember(member)) {
            _members.removeAtIndex(_members.indexOf(member)!)
        }
    }

    func containsMember(member: User) -> Bool {
        return _members.contains(member)
    }

    func updateGoalCollection(goals: GoalCollection) {
        _goals = goals
    }
}
