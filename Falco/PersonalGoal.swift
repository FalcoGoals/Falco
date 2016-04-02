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
    
    // for reinitializing of stored data
    init(user: User, uid: String, name: String, details: String, endTime: NSDate, priority: PriorityType, isCompleted: Bool, timeOfCompletion: NSDate?) {
        _user = user
        _isCompleted = isCompleted
        _timeOfCompletion = timeOfCompletion
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
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeObject(_user, forKey: Constants.userKey)
        coder.encodeBool(_isCompleted, forKey: Constants.isCompletedKey)
        if _timeOfCompletion != nil {
            coder.encodeObject(_timeOfCompletion, forKey: Constants.timeOfCompletionKey)
        }
    }
    
    required convenience init(coder decoder: NSCoder) {
        let uid = decoder.decodeObjectForKey(Constants.uidKey) as! String
        let name = decoder.decodeObjectForKey(Constants.nameKey) as! String
        let details = decoder.decodeObjectForKey(Constants.detailsKey) as! String
        let endTime = decoder.decodeObjectForKey(Constants.endTimeKey) as! NSDate
        let priority = PriorityType(rawValue: decoder.decodeIntegerForKey(Constants.priorityKey))
        let user = decoder.decodeObjectForKey(Constants.userKey) as! User
        let isCompleted = decoder.decodeBoolForKey(Constants.isCompletedKey)
        let timeOfCompletion = decoder.decodeObjectForKey(Constants.timeOfCompletionKey) as! NSDate?
        self.init(user: user, uid: uid, name: name, details: details, endTime: endTime, priority: priority!, isCompleted: isCompleted, timeOfCompletion: timeOfCompletion)
    }
}