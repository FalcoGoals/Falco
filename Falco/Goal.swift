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
    private var _uid: String
    private var _name: String
    private var _details: String
    private var _endTime: NSDate
    private var _priority: PRIORITY_TYPE
    private var _goalType: GOAL_TYPE
   // private var _timestamp: NSDate!
    private var _weight: Int!

    var identifier: String { return _uid }
    var name: String { return _name }
    var details: String { return _details }
    var endTime: NSDate { return _endTime }
    var priority: PRIORITY_TYPE { return _priority }
    var goalType: GOAL_TYPE { return _goalType }
    var weight: Int { return _weight }

    // consider adding time of creation?
    init(uid: String, name: String, details: String, endTime: NSDate, priority: PRIORITY_TYPE, goalType: GOAL_TYPE) {
        _uid = uid
        _name = name
        _details = details
        _endTime = endTime
        _priority = priority
        _goalType = goalType
        updateWeight()
    }
    
    /// sets the deadline of the goal
    func setEndTime(endTime: NSDate) {
        _endTime = endTime
        updateWeight()
    }
    
    /// Sets the priority of the goal
    func setPriority(priority: PRIORITY_TYPE) {
        _priority = priority
        updateWeight()
    }
    
    /// Determines the weight of the goal based on priority and closeness of deadline
    private func updateWeight() {
        _weight = 50    //put this here first
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