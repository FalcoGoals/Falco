//
//  Goal.swift
//  Falco
//
//  Created by Gerald on 17/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

/** 
 Overview: Protocol for all Goal objects
 SpecFields:
 name (String):               Stores the name of the goal object
 details (String):            Stores the details of the goal object
 priority (Double):           A numerical value representing the priority of the goal object
 endTime (NSDate):            Stores the goal's deadline
 id (String):                 Is unique, goals are referenced by this id
 weight (Int):                The weight is derived from the priority of the goal
 isCompleted (Bool):          Whether the goal has been completed based on the completion time
 completionTime (NSDate):     The date in which the goal was completed
 serialisedData (Dictionary): Dictionary of the goal's properties for saving to Firebase [String:
                              AnyObject]
 */

protocol Goal {
    var name: String { get set }
    var details: String { get set }
    var priority: Double { get set }
    var endTime: NSDate { get set }

    var id: String { get }
    var weight: Int { get }
    var isCompleted: Bool { get }
    var completionTime: NSDate { get }
    var serialisedData: [String: AnyObject] { get }
}

extension Goal {
    var isCompleted: Bool {
        return completionTime != Constants.incompleteTimeValue
    }
    /// smallest bubble has 15 point radius
    var weight: Int {
        return Int(round((priority + 1) * 50 + 80))
    }
}
