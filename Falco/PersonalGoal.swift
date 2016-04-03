//
//  PersonalGoal.swift
//  Falco
//
//  Created by Jing Yin Ong on 24/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class PersonalGoal: Goal {
    private var _isCompleted: Bool
    private var _timeOfCompletion: NSDate?

    var isCompleted: Bool { return _isCompleted }
    var timeOfCompletion: NSDate? { return _timeOfCompletion }
    override var serialisedData: [NSObject: AnyObject] {
        var goalData = super.serialisedData
        goalData["isCompleted"] = isCompleted
        if let completionTime = timeOfCompletion?.timeIntervalSince1970 {
            goalData["timeOfCompletion"] = completionTime
        }
        return goalData
    }

    init(uid: String = NSUUID().UUIDString, name: String, details: String, endTime: NSDate, priority: PriorityType = .Low, isCompleted: Bool = false, timeOfCompletion: NSDate? = nil) {
        _isCompleted = isCompleted
        _timeOfCompletion = timeOfCompletion
        super.init(uid: uid, name: name, details: details, endTime: endTime, priority: priority, goalType: .Personal)
    }

    init(uid: String, goalData: NSDictionary) {
        _isCompleted = goalData["isCompleted"]! as! Bool
        if let toc = goalData["timeOfCompletion"] as? NSNumber {
            _timeOfCompletion = NSDate(timeIntervalSince1970: NSTimeInterval(toc))
        }

        super.init(uid: uid, goalType: .Personal, goalData: goalData)
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
        let isCompleted = decoder.decodeBoolForKey(Constants.isCompletedKey)
        let timeOfCompletion = decoder.decodeObjectForKey(Constants.timeOfCompletionKey) as! NSDate?
        self.init(uid: uid, name: name, details: details, endTime: endTime, priority: priority!, isCompleted: isCompleted, timeOfCompletion: timeOfCompletion)
    }
}