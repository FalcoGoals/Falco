//
//  Storage.swift
//  Falco
//
//  Created by John Yong on 11/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class Storage {
    static let instance = Storage()
    var personalGoals = GoalCollection()
    var groups: [String: Group] = [:]
    var friends = [User]()
    private init() {}
}