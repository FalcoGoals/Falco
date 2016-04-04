//
//  Group.swift
//  Falco
//
//  Created by Jing Yin Ong on 21/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class Group : NSObject, NSCoding {
    private let _uid: String
    private var _name: String
    private var _members: [User]
    private var _goals: GoalCollection

    var identifier: String { return _uid }
    var name: String { return _name }
    var members: [User] { return _members }
    var goals: GoalCollection { return _goals }

    init(uid: String, name: String, users: [User], goals: GoalCollection = GoalCollection()) {
        _uid = uid
        _name = name
        _members = users
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

    
    // Save a Goal object locally
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(_uid, forKey: Constants.uidKey)
        coder.encodeObject(_name, forKey: Constants.nameKey)
        coder.encodeObject(_members, forKey: Constants.membersKey)
        coder.encodeObject(_goals, forKey: Constants.goalsKey)
    }
    
    /// Reinitialize a locally saved Goal object
    required convenience init(coder decoder: NSCoder) {
        let uid = decoder.decodeObjectForKey(Constants.uidKey) as! String
        let name = decoder.decodeObjectForKey(Constants.nameKey) as! String
        let members = decoder.decodeObjectForKey(Constants.membersKey) as! [User]
        let goals = decoder.decodeObjectForKey(Constants.goalsKey) as! [Goal]
        let goalCollection = GoalCollection(goals: goals)
        self.init (uid: uid, name: name, users: members, goals: goalCollection)
    }

}

func ==(lhs: Group, rhs: Group) -> Bool {
    return lhs.identifier == rhs.identifier
}