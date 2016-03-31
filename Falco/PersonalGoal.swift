//
//  PersonalGoal.swift
//  Falco
//
//  Created by Jing Yin Ong on 24/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class PersonalGoal: Goal {
    private var _user: User
    private var _isCompleted: Bool
    private var _timeOfCompletion: NSDate?

    var user: User { return _user }
    var isCompleted: Bool { return _isCompleted }
    var timeOfCompletion: NSDate? { return _timeOfCompletion }

    init(user: User, uid: String, name: String, details: String, endTime: NSDate, priority: PriorityType = .Low) {
        _user = user
        _isCompleted = false
        super.init(uid: uid, name: name, details: details, endTime: endTime, priority: priority, goalType: .Personal)
    }

    /// Marks the goal as completed
    func markAsComplete() {
        _isCompleted = true
        _timeOfCompletion = NSDate()
    }

    /// Marks the goal as uncompleted
    func undoMarkAsComplete() {
        _isCompleted = false
        _timeOfCompletion = nil
    }
}