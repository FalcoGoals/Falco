//
//  User.swift
//  Falco
//
//  Created by Jing Yin Ong on 21/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

/**
 Overview: Struct representing a user object
 SpecFields:
 _id (String):                Is unique, users are referenced by this id
 name (String):               Stores the name of the user
 pictureUrl (String):         Stores the url to the user's Facebook profile picture
 */
struct User: Hashable {
    private let _id: String

    var id: String { return _id }
    var name: String
    var pictureUrl: String

    var serialisedData: [String: AnyObject] {
        let userData: [String: String] = [Constants.idKey: id,
                                          Constants.nameKey: name,
                                          Constants.pictureUrlKey: pictureUrl]
        return userData
    }

    init(id: String, name: String = "", pictureUrl: String = "") {
        self._id = id
        self.name = name
        self.pictureUrl = pictureUrl
    }

    init(userData: [String: AnyObject]) {
        let id = userData[Constants.idKey]! as! String
        let name = userData[Constants.nameKey]! as! String
        let pictureUrl = userData[Constants.pictureUrlKey]! as! String
        self.init(id: id, name: name, pictureUrl: pictureUrl)
    }

    var hashValue: Int {
        return _id.hashValue
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}
