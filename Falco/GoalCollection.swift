//
//  GoalCollection.swift
//  Falco
//
//  Created by Jing Yin Ong on 22/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class GoalCollection: CustomStringConvertible {
    private var _goals: [Goal]

    var goals: [Goal] { return _goals }
    var serialisedData: [String: AnyObject] {
        var goalsData: [String: AnyObject] = [:]
        for goal in goals {
            goalsData[goal.id] = goal.serialisedData
        }
        return goalsData
    }

    var description: String {
        return goals.description
    }

    init(goals: [Goal] = []) {
        self._goals = goals
    }

    init(goalsData: AnyObject) {
        if let goalsData = goalsData as? [String: [String: AnyObject]] {
            var goals = [Goal]()
            for (goalId, goalData) in goalsData {
                let goal = PersonalGoal(id: goalId, goalData: goalData)
                goals.append(goal)
            }
            _goals = goals
        } else {
            _goals = []
        }
    }

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
        if containsGoal(goal) {
            removeGoal(goal);
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
    
    /// Marks a goal as being completed
    func markGoalComplete(goal: Goal, user: User) {
        if containsGoal(goal) {
            //removeGoal(goal)
            if var pGoal = goal as? PersonalGoal {
                pGoal.markComplete()
                _goals.append(pGoal)
                removeGoal(goal)
            } else if var gGoal = goal as? GroupGoal {
                if gGoal.markCompleteByUser(user) {
                    _goals.append(gGoal)
                    removeGoal(goal)
                }
            }
        }
    }
    
    /// Marks a goal as being uncompleted
    func markGoalIncomplete(goal: Goal, user: User) {
        if containsGoal(goal) {
            if var pGoal = goal as? PersonalGoal {
                pGoal.markIncomplete()
                _goals.append(pGoal)
                removeGoal(goal)
            } else if var gGoal = goal as? GroupGoal {
                if gGoal.markIncompleteByUser(user) {
                    _goals.append(gGoal)
                    removeGoal(goal)
                }
            }
        }
    }
    
    /// Returns whether the goal collection has any goals
    func isEmpty() -> Bool {
        return _goals.isEmpty
    }
    
    /// Returns list of goals assigned to a particular user
    /// currently at O(n^2) can be better hm
    func getGoalsAssignedToUser(user: User) -> [Goal] {
        var goalList = [Goal]()
        for goal in _goals {
            if let goal = goal as? PersonalGoal {
                goalList.append(goal)
            } else if let groupGoal = goal as? GroupGoal {
                if groupGoal.userIsAssigned(user) {
                    goalList.append(goal)
                }
            }
        }
        return goalList
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
    func sortGoalsByPriority() -> [Goal] {
        return _goals.sort({ (goal1, goal2) -> Bool in
            return goal1.priority.rawValue > goal2.priority.rawValue
        })
    }
    
    /// Sorts all goals from the soonest to latest deadline
    func sortGoalsByEndTime() -> [Goal] {
        return _goals.sort({ (goal1, goal2) -> Bool in
            return goal1.endTime.compare(goal2.endTime) != NSComparisonResult.OrderedDescending
        })
    }

    /// Sorts all goals in descending weights
    func sortGoalsByWeight() {
        _goals.sortInPlace { $0.weight > $1.weight }
    }
    
    /// Returns goals with an end time earlier than the param, not including those with the
    /// same end time as the param
    func getGoalsBeforeEndTime(endTime: NSDate) -> [Goal] {
        var goalList = [Goal]()
        for goal in _goals {
            if (!goal.endTime.earlierDate(endTime).isEqualToDate(endTime)) {
                goalList.append(goal)
            }
        }
        return goalList
    }
    
    /// Returns array of completed goals in the collection
    func getCompletedGoals() -> [Goal] {
        var completedGoals = [Goal]()
        for goal in _goals {
            if let personalGoal = goal as? PersonalGoal {
                if personalGoal.isCompleted {
                    completedGoals.append(goal)
                }
            } else if let groupGoal = goal as? GroupGoal {
                if groupGoal.isCompleted {
                    completedGoals.append(goal)
                }
            }
        }
        return completedGoals
    }
    
    /// Returns array of uncompleted goals in the collection
    func getUncompletedGoals() -> [Goal] {
        var uncompletedGoals = [Goal]()
        for goal in _goals {
            if let personalGoal = goal as? PersonalGoal {
                if !personalGoal.isCompleted {
                    uncompletedGoals.append(goal)
                }
            } else if let groupGoal = goal as? GroupGoal {
                if !groupGoal.isCompleted {
                    uncompletedGoals.append(goal)
                }
            }
        }
        return uncompletedGoals
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
    
    /// Returns the goal with a particular id
    func getGoalWithIdentifier(id: String) -> Goal? {
        for goal in _goals {
            if goal.id == id {
                return goal
            }
        }
        return nil
    }
}