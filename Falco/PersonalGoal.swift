//
//  PersonalGoal.swift
//  Falco
//
//  Created by Jing Yin Ong on 24/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

/**
 Overview: Struct representing a personal goal, which involves only one user
 SpecFields:
 _id (String):                Is unique, goals are referenced by this id
 _completionTime (NSDate):    The date in which the goal was completed
 name (String):               Stores the name of the goal object
 details (String):            Stores the details of the goal object
 priority (Double):           A numerical value representing the priority of the goal object
 endTime (NSDate):            Stores the goal's deadline
 isCompleted (Bool):          Whether the goal has been completed based on the completion time
 */
struct PersonalGoal: Goal {
    private let _id: String
    private var _completionTime: NSDate

    // MARK: Properties

    var name: String
    var details: String
    var priority: Double
    var endTime: NSDate

    var id: String { return _id }
    var completionTime: NSDate { return _completionTime }

    var serialisedData: [String: AnyObject] {
        let goalData: [String: AnyObject] = [Constants.nameKey: name,
                                             Constants.detailsKey: details,
                                             Constants.priorityKey: priority,
                                             Constants.endTimeKey: endTime.timeIntervalSince1970,
                                             Constants.completionTimeKey: completionTime.timeIntervalSince1970]
        return goalData
    }

    // MARK: Init

    init(id: String = NSUUID().UUIDString, name: String, details: String, priority: Double = 0, endTime: NSDate, completionTime: NSDate = Constants.incompleteTimeValue) {
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
        let priority = goalData[Constants.priorityKey]! as! Double
        let endTime = NSDate(timeIntervalSince1970: NSTimeInterval(goalData[Constants.endTimeKey] as! NSNumber))
        let completionTime = NSDate(timeIntervalSince1970: NSTimeInterval(goalData[Constants.completionTimeKey] as! NSNumber))
        self.init(id: id, name: name, details: details, priority: priority, endTime: endTime, completionTime: completionTime)
    }

    // MARK: Methods (mutating)

    mutating func markComplete() {
        _completionTime = NSDate()
    }

    mutating func markIncomplete() {
        _completionTime = Constants.incompleteTimeValue
    }
}
