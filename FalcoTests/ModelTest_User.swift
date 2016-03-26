//
//  UserTest.swift
//  Falco
//
//  Created by Jing Yin Ong on 25/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import XCTest

class ModelTest_User: XCTestCase {
    var A = User(uid: "id1", name: "ladybug")

    func testName() {
        XCTAssertEqual("ladybug", A.name)
    }
    
    func testIdentifier() {
        XCTAssertEqual("id1", A.identifier)
    }
    
}