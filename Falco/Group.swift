//
//  Group.swift
//  Falco
//
//  Created by Jing Yin Ong on 21/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class Group : Equatable {
    private let _uid: String
    private var _name: String
    private var _members: [User]
    private var _goals: GoalCollection
    
    var identifier: String { return _uid }
    var name: String { return _name }
    var members: [User] { return _members }
    var goals: GoalCollection { return _goals }
    
    init (uid: String, name: String, users: [User]) {
        _uid = uid
        _name = name
        _members = users
        _goals = GoalCollection(goals: [])
    }
    
    init (uid: String, name: String, users: [User], goals: GoalCollection) {
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
    
    /// add to assignee as well
/**    func addGoal(goal: Goal) {
        _goals.addGoal(goal)
    }
    
    /// Removes goal from the group, and unassigns it from the users
    func removeGoal(goal: Goal) {
        _goals.removeGoal(goal)
    }
    
    /// Returns an array of the group's goals
    func getAllGoals() -> [Goal] {
        return _goals.getAllGoals()
    }
    
    /// Returns whether the group has the param goal
    func containsGoal(goal: Goal) -> Bool {
        return _goals.containsGoal(goal)
    }*/
    
}

func ==(lhs: Group, rhs: Group) -> Bool {
    return lhs.identifier == rhs.identifier
}