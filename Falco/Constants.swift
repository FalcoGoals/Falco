//
//  Constants.swift
//  Falco
//
//  Created by Jing Yin Ong on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

struct Constants {
    // Keys used for serialisation/deserialisation of data
    static let idKey = "id"
    static let nameKey = "name"
    static let detailsKey = "details"
    static let priorityKey = "priority"
    static let endTimeKey = "endTime"
    static let completionTimeKey = "completionTime"
    static let userCompletionTimesKey = "userCompletionTimes"
    static let membersKey = "members"
    static let goalsKey = "goals"

    // Special values
    static let incompleteTimeValue = NSDate.distantPast()
    
    // Segue identifiers
    static let addGroupSegue = "showGroupAdd"
    static let goalEditSegue = "showGoalEditView"
    static let groupChatSegue = "showChatView"
    static let groupBubblesSegue = "showGroupBubblesView"
    
    static let emptyString = ""
    static let groupSearchbarPlaceholder = "Find a group"
    static let groupSearchScope = "All"
    
    // Groups tableview
    static let groupCellID = "groupCell"
    static let groupFooterHeight = CGFloat(10)
    static let groupCellCornerRadius = CGFloat(30)
    static let groupCellBgColor = UIColor(red: 13/255, green: 41/255, blue: 84/255, alpha: 0.7)
}