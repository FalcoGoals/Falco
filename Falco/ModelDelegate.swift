//
//  ModelDelegate.swift
//  Falco
//
//  Created by John Yong on 15/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

protocol GoalModelDelegate {
    func didUpdateGoal(goal: Goal)
    func didCompleteGoal(goal: Goal) -> Goal?
    func didCompleteGoal(goalId: String, groupId: String?) -> Goal?
    func getGoal(goalId: String, groupId: String?) -> Goal?
    func getGoals(groupId: String?) -> GoalCollection?
}

protocol GroupModelDelegate {
    func getGroups() -> [Group]
    func didUpdateGroup(group: Group, callback: (() -> ())?)
    func refreshGroups(callback: (() -> ())?)
}

protocol Savable {
    func didSaveGoal(goal: Goal)
    func didSaveGroup(group: Group)
}

protocol ModelDelegate: GoalModelDelegate, GroupModelDelegate {
}