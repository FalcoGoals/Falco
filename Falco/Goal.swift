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
    var priority: PRIORITY_TYPE
    var weight: Int {
        return priority.rawValue * 5 + 10
    }

    private var _uid: String
    private var _goalType: GOAL_TYPE
   // private var _timestamp: NSDate!
    private var _weight: Int!

    var identifier: String { return _uid }
    var goalType: GOAL_TYPE { return _goalType }

    // consider adding time of creation?
    init(uid: String, name: String, details: String, endTime: NSDate, priority: PRIORITY_TYPE, goalType: GOAL_TYPE) {
        self.name = name
        self.details = details
        self.endTime = endTime
        self.priority = priority
        _uid = uid
        _goalType = goalType
    }

    var hashValue: Int {
        return _uid.hashValue
    }
}

func ==(lhs: Goal, rhs: Goal) -> Bool {
    return lhs.identifier == rhs.identifier
}

enum PRIORITY_TYPE: Int {
    case low, mid, high
}

enum GOAL_TYPE: Int {
    case personal, group
}