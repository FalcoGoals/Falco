//
//  Goal.swift
//  Falco
//
//  Created by Gerald on 17/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

// Model for GoalBubble
class Goal: NSObject, NSCoding {
    private var _uid: String
    private var _name: String
    private var _details: String
    private var _endTime: NSDate
    private var _priority: PriorityType
    private var _goalType: GoalType
    // private var _timestamp: NSDate!
    
    var identifier: String { return _uid }
    var name: String { return _name }
    var endTime: NSDate { return _endTime }
    var details: String { return _details }
    var priority: PriorityType { return _priority }
    var goalType: GoalType { return _goalType }
    var weight: Int { return priority.rawValue * 50 + 100 }
    var serialisedData: [NSObject: AnyObject] {
        let goalData: [NSObject: AnyObject] = ["name": name,
                                               "details": details,
                                               "endTime": endTime.timeIntervalSince1970,
                                               "priority": priority.rawValue]
        return goalData
    }

    // consider adding time of creation?
    init(uid: String, name: String, details: String, endTime: NSDate, priority: PriorityType, goalType: GoalType) {
        self._uid = uid
        self._name = name
        self._details = details
        self._endTime = endTime
        self._priority = priority
        self._goalType = goalType
    }

    init(uid: String, goalType: GoalType, goalData: NSDictionary) {
        self._uid = uid
        self._name = goalData["name"]! as! String
        self._details = goalData["details"]! as! String
        self._endTime = NSDate(timeIntervalSince1970: NSTimeInterval(goalData["endTime"] as! NSNumber))
        self._priority = PriorityType(rawValue: goalData["priority"]! as! Int)!
        self._goalType = goalType
    }

    override var hashValue: Int {
        return _uid.hashValue
    }
    
    func setName(name: String) {
        _name = name
    }
    
    func setEndTime(endTime: NSDate) {
        _endTime = endTime
    }
    
    func setDetails(details: String) {
        _details = details
    }
    
    func setPriority(priority: PriorityType) {
        _priority = priority
    }
    
    // Save a Goal object locally
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(_uid, forKey: Constants.uidKey)
        coder.encodeObject(_name, forKey: Constants.nameKey)
        coder.encodeObject(_details, forKey: Constants.detailsKey)
        coder.encodeObject(_endTime, forKey: Constants.endTimeKey)
        coder.encodeInteger(_priority.rawValue, forKey: Constants.priorityKey)
        coder.encodeInteger(_goalType.rawValue, forKey: Constants.goalTypeKey)
    }
    
    /// Reinitialize a locally saved Goal object
    required convenience init(coder decoder: NSCoder) {
        let uid = decoder.decodeObjectForKey(Constants.uidKey) as! String
        let name = decoder.decodeObjectForKey(Constants.nameKey) as! String
        let details = decoder.decodeObjectForKey(Constants.detailsKey) as! String
        let endTime = decoder.decodeObjectForKey(Constants.endTimeKey) as! NSDate
        let priority = PriorityType(rawValue: decoder.decodeIntegerForKey(Constants.priorityKey))
        let goalType = GoalType(rawValue: decoder.decodeIntegerForKey(Constants.goalTypeKey))
        self.init(uid: uid, name: name, details: details, endTime: endTime, priority: priority!, goalType: goalType!)
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