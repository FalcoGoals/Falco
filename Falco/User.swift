//
//  User.swift
//  Falco
//
//  Created by Jing Yin Ong on 21/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class User: Hashable {
    private var _name: String
    private let _uid: String
    // private var _groups = [Group]()

    var name: String { return _name }
    var identifier: String { return _uid }
    //var groups: [Group] { return _groups }

    init(uid: String, name: String) {
        _uid = uid
        _name = name
    }

    var hashValue: Int {
        return _uid.hashValue
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.identifier == rhs.identifier
}