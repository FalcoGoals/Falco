//
//  GoalBubble.swift
//  Pegasus
//
//  Created by Gerald on 17/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

// Model for GoalBubble
class GoalBubble {
  private var _weight: Int!
  private var _name: String!
  private var _timestamp: NSDate!

  var weight: Int { return _weight }
  var name: String { return _name }

  init(name: String, weight: Int = 50) {
    self._name = name
    self._weight = weight
  }
}
