//
//  Goal.swift
//  Falco
//
//  Created by Gerald on 17/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

protocol Goal {
    var name: String { get set }
    var details: String { get set }
    var priority: PriorityType { get set }
    var endTime: NSDate { get set }

    var id: String { get }
    var weight: Int { get }
    var isCompleted: Bool { get }
    var completionTime: NSDate { get }
    var serialisedData: [String: AnyObject] { get }
}

extension Goal {
    var isCompleted: Bool {
        return completionTime != NSDate.distantPast()
    }
    var weight: Int {
        return priority.rawValue * 70 + 50
    }
}

enum PriorityType: Int {
    case Low, Mid, High
}
