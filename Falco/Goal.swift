//
//  Goal.swift
//  Falco
//
//  Created by Gerald on 17/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

// Model for GoalBubble
class Goal: Hashable {
    var name: String
    var details: String
    var endTime: NSDate
    var priority: PriorityType
    var weight: Int {
        return priority.rawValue * 50 + 100
    }

    private var _uid: String
    private var _goalType: GoalType
    // private var _timestamp: NSDate!

    var identifier: String { return _uid }
    var goalType: GoalType { return _goalType }

    // consider adding time of creation?
    init(id: String, name: String, details: String, endTime: NSDate, priority: PriorityType, goalType: GoalType) {
        self.name = name
        self.details = details
        self.endTime = endTime
        self.priority = priority
        _uid = id
        _goalType = goalType
    }

    var hashValue: Int {
        return _uid.hashValue
    }
}

func ==(lhs: Goal, rhs: Goal) -> Bool {
    return lhs.identifier == rhs.identifier
}

enum PriorityType: Int {
    case Low, Mid, High
}

enum GoalType: Int {
    case Personal, Group
}