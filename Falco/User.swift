//
//  User.swift
//  Falco
//
//  Created by Jing Yin Ong on 21/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
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

    override var hashValue: Int {
        return _uid.hashValue
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(_name, forKey: Constants.nameKey)
        coder.encodeObject(_uid, forKey: Constants.uidKey)
    }
    
    required convenience init(coder decoder: NSCoder) {
        let name = decoder.decodeObjectForKey(Constants.nameKey) as! String
        let uid = decoder.decodeObjectForKey(Constants.uidKey) as! String
        self.init(uid: uid, name: name)
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.identifier == rhs.identifier
}