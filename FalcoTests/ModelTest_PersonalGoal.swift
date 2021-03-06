//
//  PersonalGoalModelTest.swift
//  Falco
//
//  Created by Jing Yin Ong on 25/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import XCTest

class ModelTest_PersonalGoal: XCTestCase {
    let userA = User(id: "user1", name: "ladybug")
    var a: PersonalGoal?
    
    override func setUp() {
        super.setUp()
        a = PersonalGoal(name: "buggy", details: "no details", endTime: NSDate())
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUndoMarkAsComplete() {
        XCTAssertEqual(false, a!.isCompleted)
        a!.markComplete()
        XCTAssertEqual(true, a!.isCompleted)
        a!.markIncomplete()
        XCTAssertEqual(false, a!.isCompleted)
    }
    
}