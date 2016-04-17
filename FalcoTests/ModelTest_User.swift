//
//  UserTest.swift
//  Falco
//
//  Created by Jing Yin Ong on 25/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import XCTest

class ModelTest_User: XCTestCase {
    var A = User(id: "id1", name: "ladybug")
    var B = User(id: "id2", name: "grasshopper", pictureUrl: "grasshopper.png")
    
    func testName() {
        XCTAssertEqual("ladybug", A.name)
    }
    
    func testIdentifier() {
        XCTAssertEqual("id1", A.id)
    }
    
    func testPicture() {
        XCTAssertEqual("grasshopper.png", B.pictureUrl)
    }
}