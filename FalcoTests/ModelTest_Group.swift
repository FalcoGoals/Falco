//
//  ModelTest_Group.swift
//  Falco
//
//  Created by Jing Yin Ong on 25/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import XCTest

class ModelTest_Group: XCTestCase {
    let userA = User(uid: "uid1", name: "ladybug")
    let userB = User(uid: "uid2", name: "beetle")
    let userC = User(uid: "uid3", name: "grasshopper")
    var group: Group?
    
    override func setUp() {
        super.setUp()
        group = Group(uid: "groupid1", name: "insects", users: [userA, userB])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAddMember() {
        group!.addMember(userC)
        XCTAssertEqual(Set([userA, userB, userC]), Set(group!.members))
        group!.addMember(userB)
        XCTAssertEqual(Set([userA, userB, userC]), Set(group!.members))
    }

    func testRemoveMember() {
        group!.removeMember(userA)
        XCTAssertEqual([userB], group!.members)
        group!.removeMember(userC)
        XCTAssertEqual([userB], group!.members)
    }
    
    func testContainsMember() {
        XCTAssert(group!.containsMember(userB))
        XCTAssert(!group!.containsMember(userC))
    }

    
}
