//
//  GoalCollection.swift
//  Falco
//
//  Created by Jing Yin Ong on 22/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

/**
 Overview: Class representing a collection of Goal objects
 SpecFields:
 _goals ([Goal]):  Stores an array of all the goal objects in the collection
 */
class GoalCollection: CustomStringConvertible {
    private var _goals: [Goal]

    // MARK: Properties

    var goals: [Goal] { return _goals }
    var count: Int { return _goals.count }
    var isEmpty: Bool { return _goals.isEmpty }
    var serialisedData: [String: AnyObject] {
        var goalsData: [String: AnyObject] = [:]
        for goal in goals {
            goalsData[goal.id] = goal.serialisedData
        }
        return goalsData
    }

    var completeGoals: GoalCollection {
        return GoalCollection(goals: _goals.filter({$0.isCompleted}))
    }

    var incompleteGoals: GoalCollection {
        return GoalCollection(goals: _goals.filter({!$0.isCompleted}))
    }

    var assignedGroupGoals: GoalCollection {
        return GoalCollection(goals: _goals.filter({$0 is GroupGoal && ($0 as! GroupGoal).isUserAssigned(Storage.instance.user)}))
    }

    var relevantGoals: GoalCollection {
        return GoalCollection(goals: _goals.filter({!($0 is GroupGoal && !($0 as! GroupGoal).isUserAssigned(Storage.instance.user))}))
    }

    var description: String {
        return goals.description
    }

    // MARK: Init

    init(goals: [Goal] = []) {
        self._goals = goals
    }

    convenience init(goalsData: AnyObject) {
        if let goalsData = goalsData as? [String: [String: AnyObject]] {
            var goals = [Goal]()
            for (goalId, goalData) in goalsData {
                let goal = PersonalGoal(id: goalId, goalData: goalData)
                goals.append(goal)
            }
            self.init(goals: goals)
        } else {
            self.init()
        }
    }

    // MARK: Methods (mutating)

    /// Returns whether a goal is contained in the collection
    func containsGoal(goal: Goal) -> Bool {
        for i in 0..<_goals.count {
            if _goals[i].id == goal.id {
                return true
            }
        }
        return false
    }

    /// Adds a goal into the collection if it is not previously contained
    /// Else replaces the original goal with the new goal
    func updateGoal(goal: Goal) {
        for i in 0..<_goals.count {
            if _goals[i].id == goal.id {
                _goals[i] = goal
                return
            }
        }
        _goals.append(goal);
    }
    
    /// Removes a particular goal from the collection
    func removeGoal(goal: Goal) {
        for i in 0..<_goals.count {
            if _goals[i].id == goal.id {
                _goals.removeAtIndex(i)
                return
            }
        }
    }
    
    /// Clears the collection of all goals
    func removeAllGoals() {
        _goals.removeAll()
    }
    
    /// Marks a goal as complete
    func markGoalComplete(goal: Goal, user: User) {
        let existingGoal = getGoalWithIdentifier(goal.id)
        guard existingGoal != nil else {
            return
        }

        if var pGoal = existingGoal as? PersonalGoal {
            pGoal.markComplete()
            updateGoal(pGoal)
        } else if var gGoal = existingGoal as? GroupGoal {
            if gGoal.markCompleteByUser(user) {
                updateGoal(gGoal)
            }
        }
    }
    
    /// Marks a goal as incomplete
    func markGoalIncomplete(goal: Goal, user: User) {
        let existingGoal = getGoalWithIdentifier(goal.id)
        guard existingGoal != nil else {
            return
        }

        if var pGoal = existingGoal as? PersonalGoal {
            pGoal.markIncomplete()
            updateGoal(pGoal)
        } else if var gGoal = existingGoal as? GroupGoal {
            if gGoal.markIncompleteByUser(user) {
                updateGoal(gGoal)
            }
        }
    }
    
    /// Unassigns a goal from a particular user
    /// If the goal is a personal goal, it will be removed
    /// If the goal is a group goal, the user will be unassigned from it
    func unassignGoalFromUser(goal: Goal, user: User) {
        if containsGoal(goal) {
            removeGoal(goal)
            if var gGoal = goal as? GroupGoal {
                gGoal.removeUser(user)
                _goals.append(gGoal)
            }
        }
    }
    
    /// Sorts all goals from highest priority to lowest priority
    func sortGoalsByPriority() {
        _goals.sortInPlace({ (goal1, goal2) -> Bool in
            return goal1.priority > goal2.priority
        })
    }
    
    /// Sorts all goals from the soonest to latest deadline
    func sortGoalsByEndTime() {
        _goals.sortInPlace({ (goal1, goal2) -> Bool in
            return goal1.endTime.compare(goal2.endTime) != NSComparisonResult.OrderedDescending
        })
    }

    /// Sorts all goals in descending weights
    func sortGoalsByWeight() {
        _goals.sortInPlace { $0.weight > $1.weight }
    }

    // MARK: Methods (non-mutating)

    /// Returns the goal with a particular id
    func getGoalWithIdentifier(id: String) -> Goal? {
        for goal in _goals {
            if goal.id == id {
                return goal
            }
        }
        return nil
    }

    /// Returns an array of goals which have the same name as the param
    func getGoalsWithName(name: String) -> [Goal] {
        var goalsWithName = [Goal]()
        for goal in _goals {
            if goal.name == name {
                goalsWithName.append(goal)
            }
        }
        return goalsWithName
    }

    /// Returns list of goals assigned to a particular user
    func getGoalsAssignedToUser(user: User) -> [Goal] {
        var goalList = [Goal]()
        for goal in _goals {
            if let goal = goal as? PersonalGoal {
                goalList.append(goal)
            } else if let groupGoal = goal as? GroupGoal {
                if groupGoal.isUserAssigned(user) {
                    goalList.append(goal)
                }
            }
        }
        return goalList
    }

    /// Returns goals with an end time earlier than the param, not including those with the
    /// same end time as the param
    func getGoalsBeforeEndTime(endTime: NSDate) -> [Goal] {
        var goalList = [Goal]()
        for goal in _goals {
            if !goal.endTime.earlierDate(endTime).isEqualToDate(endTime) {
                goalList.append(goal)
            }
        }
        return goalList
    }
}