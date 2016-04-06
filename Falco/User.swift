//
//  User.swift
//  Falco
//
//  Created by Jing Yin Ong on 21/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

struct User: Hashable {
    private var _name: String
    private let _id: String
    private let _pictureUrl: String

    var name: String { return _name }
    var id: String { return _id }
    var pictureUrl: String { return _pictureUrl }

    init(id: String, name: String = "", pictureUrl: String = "") {
        _id = id
        _name = name
        _pictureUrl = pictureUrl
    }

    var hashValue: Int {
        return _id.hashValue
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}
