//
//  PersonalGoal.swift
//  Falco
//
//  Created by Jing Yin Ong on 24/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

struct PersonalGoal: Goal {
    private let _id: String
    private var _completionTime: NSDate?

    var name: String
    var details: String
    var priority: PriorityType
    var endTime: NSDate

    var id: String { return _id }
    var weight: Int { return priority.rawValue * 50 + 100 }
    var isCompleted: Bool { return _completionTime != nil }
    var completionTime: NSDate? { return _completionTime }

    var serialisedData: [String: AnyObject] {
        var goalData: [String: AnyObject] = [Constants.nameKey: name,
                                             Constants.detailsKey: details,
                                             Constants.priorityKey: priority.rawValue,
                                             Constants.endTimeKey: endTime.timeIntervalSince1970]
        if let completionTime = _completionTime?.timeIntervalSince1970 {
            goalData[Constants.completionTimeKey] = completionTime
        }
        return goalData
    }

    init(id: String = NSUUID().UUIDString, name: String, details: String, priority: PriorityType = .Low, endTime: NSDate, completionTime: NSDate? = nil) {
        self._id = id
        self.name = name
        self.details = details
        self.priority = priority
        self.endTime = endTime
        self._completionTime = completionTime
    }

    init(id: String, goalData: [String: AnyObject]) {
        let name = goalData[Constants.nameKey]! as! String
        let details = goalData[Constants.detailsKey]! as! String
        let priority = PriorityType(rawValue: goalData[Constants.priorityKey]! as! Int)!
        let endTime = NSDate(timeIntervalSince1970: NSTimeInterval(goalData[Constants.endTimeKey] as! NSNumber))
        let completionTime: NSDate?
        if let toc = goalData[Constants.completionTimeKey] as? NSNumber {
            completionTime = NSDate(timeIntervalSince1970: NSTimeInterval(toc))
        } else {
            completionTime = nil
        }
        self.init(id: id, name: name, details: details, priority: priority, endTime: endTime, completionTime: completionTime)
    }

    mutating func markComplete() {
        _completionTime = NSDate()
    }

    mutating func markIncomplete() {
        _completionTime = nil
    }
}
