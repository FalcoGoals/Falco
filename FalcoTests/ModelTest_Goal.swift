//
//  GoalModelTest.swift
//  Falco
//
//  Created by Jing Yin Ong on 25/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import XCTest

class ModelTest_Goal: XCTestCase {
    let timeA = NSDate(timeIntervalSinceReferenceDate: 500000000)
    let timeB = NSDate(timeIntervalSinceReferenceDate: 450000000)
    let timeC = NSDate(timeIntervalSinceReferenceDate: 550000000)
    var a: Goal?//= Goal(uid: "id1", name: "goal1", endTime: timeA, priority: .high, goalType: .personal)
    var b: Goal?
    
    override func setUp() {
        super.setUp()
        a = Goal(uid: "id1", name: "goal1", endTime: timeA, priority: .high, goalType: .personal)
        b = Goal(uid: "id2", name: "goal2", endTime: timeB, priority: .mid, goalType: .group)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetEndTime() {
        a!.setEndTime(timeB)
        XCTAssertEqual(timeB, a!.endTime)
        b!.setEndTime(timeC)
        XCTAssertEqual(timeC, b!.endTime)
    }
    
    func testSetPriority() {
        a!.setPriority(.low)
        b!.setPriority(.high)
        XCTAssertEqual(PRIORITY_TYPE.low, a!.priority)
        XCTAssertEqual(PRIORITY_TYPE.high, b!.priority)
    }
    
    func testUpdateWeight() {
        
    }
    
}