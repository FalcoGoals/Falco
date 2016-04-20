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
    static let pictureUrlKey = "pictureUrl"

    // Special values
    static let incompleteTimeValue = NSDate.distantPast()
    
    // Segue identifiers
    static let addGroupSegue = "showGroupAdd"
    static let goalEditSegue = "showGoalEditView"
    static let groupEditSegue = "showGroupEditView"
    static let groupChatSegue = "showChatView"
    static let groupBubblesSegue = "showGroupBubblesView"
    
    static let emptyString = ""
    static let groupSearchbarPlaceholder = "Find a group"
    static let groupSearchScope = "All"
    
    // Goal edit view
    static let nameRow = 0
    static let dateRow = 1
    static let assignedUsersLabelRow = 4
    static let descriptionRow = 6
    static let datePickerRowHeight: CGFloat = 100
    static let assignedUsersTableRowHeight: CGFloat = 100
    static let newGoalTitle = "New Goal"
    static let lowPriorityIndex = 0
    static let mediumPriorityIndex = 1
    static let highPriorityIndex = 2
    static let usersCellTableBorderWidth: CGFloat = 1
    static let usersCellTableCornerRadius: CGFloat = 5
    static let usersCellTableBorderColor = UIColor(red: 0, green: 118/255, blue: 1, alpha: 1).CGColor
    static let tableViewEstimatedRowHeight: CGFloat = 45
    static let detailsFieldBorderWidth: CGFloat = 1
    static let detailsFieldCornerRadius: CGFloat = 5
    static let detailsFieldBorderColor = UIColor(red: 0, green: 118/255, blue: 1, alpha: 1).CGColor
    
    // Groups tableview
    static let groupCellID = "groupCell"
    static let groupFooterHeight: CGFloat = 10
    static let groupCellCornerRadius: CGFloat = 30
    static let groupCellBgColor = UIColor(red: 13/255, green: 41/255, blue: 84/255, alpha: 0.7)
    static let numGoalPreview = 3
    static let goalPreviewSpacing: CGFloat = 20
    
    // GroupAdd tableview
    static let friendCellID = "friendCell"
    static let okayMessage = "Okay"
    static let groupCreationFailMsg = "Failed to create group"
    static let nameReqMsg = "A group name is required"
    static let membersReqMsg = "Please select members to join the group"
    static let groupNamePlaceholderColor = UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1)

    // Group members tableview
    static let userCellID = "userCell"
    static let groupMemberCellID = "groupMemberCell"
    
    // User cell
    static let uncompletedDateLabel = "(not done)"
    
    // BubbleScene special values
    static let bubbleOffsetValue: CGFloat = 100
    static let bubbleOffsetIncrement: CGFloat = 50
    static let lowestPathPoint: CGFloat = -9999
    static let lowestYValue = 0
    static let chatBubbleRadius: CGFloat = 40
    static let chatBubbleOffset: CGFloat = 100
    
    // BubbleCell special values
    static let drawnToGapRatio: CGFloat = 9 / 10
    static let bubbleBorderWidth: CGFloat = 2
    static let bubbleScaleFactor: CGFloat = 1.05
    static let bubbleCellLabelFontSize: CGFloat = 20
    
    // GoalBubble special values
    static let minRadius: CGFloat = 50
    static let maxRadius: CGFloat = 300
    static let desaturateMultiplier = 0.8
    static let labelFontSize: CGFloat = 25
    static let labelFontName = "System-Bold"
    static let labelName = "label"
    
    // ChatBubble
    static let chatName = "chat"
    static let chatScaleFactor: CGFloat = 1.5
    
    // Firebase
    static let messagesRefURL = "https://amber-torch-6648.firebaseio.com/messages"
    static let typingRefURL = "https://amber-torch-6648.firebaseio.com/typing"
    
    // Messages
    static let textKey = "text"
    static let senderIDKey = "senderID"
    static let senderNameKey = "senderName"
}