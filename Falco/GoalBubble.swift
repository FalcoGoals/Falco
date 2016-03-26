//
//  GoalBubble.swift
//  Falco
//
//  Created by Gerald on 17/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

// Model for GoalBubble
class GoalBubble {
  var name: String!
  var details: String!
  var priority: Int!
  var deadline: NSDate!

  private var timestamp: NSDate!

  var weight: Int {
    return priority
  }

  init(name: String, details: String, priority: Int, deadline: NSDate) {
    self.name = name
    self.details = details
    self.priority = priority
    self.deadline = deadline
  }
}
