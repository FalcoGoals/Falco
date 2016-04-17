//
//  ModelTest_GroupGoal.swift
//  Falco
//
//  Created by Jing Yin Ong on 25/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import XCTest

class ModelTest_GroupGoal: XCTestCase {
    let userA = User(id: "uid1", name: "ladybug")
    let userB = User(id: "uid2", name: "beetle")
    let userC = User(id: "uid3", name: "grasshopper")
    var goal = GroupGoal(groupId: "gid1", name: "score", details: "arsenal dood", endTime: NSDate())

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddUser() {
        goal.addUser(userA)
        goal.addUser(userB)
        XCTAssertEqual(Set([userA, userB]), Set(goal.usersAssigned))
    }
    
    func testRemoveUser() {
        goal.addUser(userA)
        goal.addUser(userB)
        goal.removeUser(userA)
        XCTAssertEqual([userB], goal.usersAssigned)
        goal.removeUser(userC)
        XCTAssertEqual([userB], goal.usersAssigned)
    }
    
    func testRemoveAllUsers() {
        goal.addUser(userA)
        goal.addUser(userC)
        goal.removeAllUsers()
        XCTAssertEqual([], goal.usersAssigned)
        
        goal.addUser(userC)
        XCTAssertEqual([userC], goal.usersAssigned)
    }
    
    func testUserIsAssigned() {
        goal.addUser(userB)
        goal.addUser(userC)
        XCTAssert(goal.isUserAssigned(userB))
        XCTAssert(goal.isUserAssigned(userC))
        XCTAssert(!goal.isUserAssigned(userA))
    }
    
    func testCompletedByUser() {
        goal.addUser(userB)
        goal.addUser(userC)
        goal.markCompleteByUser(userB)
        
        XCTAssertEqual(Set([userB]), Set(goal.usersCompleted))
        goal.markCompleteByUser(userA)
        XCTAssertEqual(Set([userB]), Set(goal.usersCompleted))
    }
    
    func testIsCompletedByUser() {
        goal.addUser(userB)
        goal.addUser(userC)
        goal.markCompleteByUser(userB)
        XCTAssert(goal.isCompletedByUser(userB))
        XCTAssert(!goal.isCompletedByUser(userC))
        XCTAssert(!goal.isCompletedByUser(userA))
    }
    
    func testUncompleteByUser() {
        goal.addUser(userB)
        goal.addUser(userC)
        goal.markCompleteByUser(userB)
        goal.markCompleteByUser(userC)
        goal.markIncompleteByUser(userB)
        XCTAssertEqual([userC], goal.usersCompleted)
        goal.markIncompleteByUser(userA)
        XCTAssertEqual([userC], goal.usersCompleted)
    }
    
    func testGetCompletedDate() {
        goal.addUser(userB)
        goal.addUser(userC)
        goal.markCompleteByUser(userB)
        XCTAssertEqual(NSDate.distantPast(), goal.completionTime)
        goal.markCompleteByUser(userC)
        let firstDate = goal.completionTime
        goal.markIncompleteByUser(userB)
        goal.markCompleteByUser(userB)
        XCTAssertEqual(goal.completionTime, goal.completionTime.laterDate(firstDate))
    }
    
    func testIsCompleted() {
        goal.addUser(userB)
        goal.addUser(userC)
        goal.markCompleteByUser(userB)
        XCTAssert(!goal.isCompleted)
        goal.markCompleteByUser(userC)
        XCTAssert(goal.isCompleted)
        
        goal.markIncompleteByUser(userA)
        XCTAssert(goal.isCompleted)
        goal.markIncompleteByUser(userB)
        XCTAssert(!goal.isCompleted)
    }
    
    func testGetUsersWhoCompleted() {
        goal.addUser(userA)
        goal.addUser(userB)
        goal.addUser(userC)
        
        goal.markCompleteByUser(userA)
        XCTAssertEqual([userA], goal.usersCompleted)
        goal.markCompleteByUser(userB)
        XCTAssertEqual(Set([userA, userB]), Set(goal.usersCompleted))
        goal.markCompleteByUser(userC)
        XCTAssertEqual(Set([userA, userB, userC]), Set(goal.usersCompleted))
        
        goal.markIncompleteByUser(userB)
        XCTAssertEqual(Set([userA, userC]), Set(goal.usersCompleted))
    }
    
    func testGetNumberOfUsersAssigned() {
        goal.addUser(userA)
        XCTAssertEqual(1, goal.usersAssignedCount)
        goal.addUser(userB)
        goal.addUser(userC)
        XCTAssertEqual(3, goal.usersAssignedCount)
        goal.removeUser(userB)
        XCTAssertEqual(2, goal.usersAssignedCount)
        goal.removeAllUsers()
        XCTAssertEqual(0, goal.usersAssignedCount)
    }

}
