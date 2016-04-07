//
//  User.swift
//  Falco
//
//  Created by Jing Yin Ong on 21/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

struct User: Hashable {
    private let _id: String

    var id: String { return _id }
    var name: String
    var pictureUrl: String

    init(id: String, name: String = "", pictureUrl: String = "") {
        self._id = id
        self.name = name
        self.pictureUrl = pictureUrl
    }

    var hashValue: Int {
        return _id.hashValue
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}
