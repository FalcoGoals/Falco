//
//  Group.swift
//  Falco
//
//  Created by Jing Yin Ong on 21/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class Group: CustomStringConvertible {
    private let _id: String
    private var _members: [User]

    // MARK: Properties

    var id: String { return _id }
    var name: String
    var members: [User] { return _members }
    var goals: GoalCollection
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

    var description: String {
        return "<Group id: \(id), name: \"\(name)\", members: \(members), goals: \(goals)>"
    }

    // MARK: Init

    init(id: String = NSUUID().UUIDString, creator: User? = nil, name: String, members: [User], goals: GoalCollection = GoalCollection()) {
        self._id = id
        self.name = name
        self._members = members
        if let creator = creator {
            self._members += [creator]
        }
        self.goals = goals
    }

    convenience init(id: String, groupData: [String: AnyObject]) {
        let name = groupData[Constants.nameKey]! as! String
        var members = [User]()
        let memberData = groupData[Constants.membersKey]! as! [String: AnyObject]
        for (memberId, _) in memberData {
            members.append(User(id: memberId))
        }
        var goals = [Goal]()
        let goalsData = groupData[Constants.goalsKey]! as! [String: [String: AnyObject]]
        for (goalId, goalData) in goalsData {
            goals.append(GroupGoal(id: goalId, goalData: goalData))
        }
        self.init(id: id, name: name, members: members, goals: GoalCollection(goals: goals))
    }

    // MARK: Methods

    func containsMember(member: User) -> Bool {
        return _members.contains(member)
    }

    func addMember(member: User) {
        _members.append(member)
    }

    func removeMember(member: User) {
        if (containsMember(member)) {
            _members.removeAtIndex(_members.indexOf(member)!)
        }
    }
}
