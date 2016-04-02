//
//  ModelTest_GroupGoal.swift
//  Falco
//
//  Created by Jing Yin Ong on 25/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import XCTest

class ModelTest_GroupGoal: XCTestCase {
    let userA = User(uid: "uid1", name: "ladybug")
    let userB = User(uid: "uid2", name: "beetle")
    let userC = User(uid: "uid3", name: "grasshopper")
    let goal = GroupGoal(uid: "gid1", name: "score", details: "bood", endTime: NSDate())

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
        XCTAssertEqual(Set([userA, userB]), Set(goal.assignedUsers))
    }
    
    func testRemoveUser() {
        goal.addUser(userA)
        goal.addUser(userB)
        goal.removeUser(userA)
        XCTAssertEqual([userB], goal.assignedUsers)
        goal.removeUser(userC)
        XCTAssertEqual([userB], goal.assignedUsers)
    }
    
    func testRemoveAllUsers() {
        goal.addUser(userA)
        goal.addUser(userC)
        goal.removeAllUsers()
        XCTAssertEqual([], goal.assignedUsers)
        
        goal.addUser(userC)
        XCTAssertEqual([userC], goal.assignedUsers)
    }
    
    /// Checks whether the goal has been assigned to the input user
    func testUserIsAssigned() {
        goal.addUser(userB)
        goal.addUser(userC)
        XCTAssert(goal.userIsAssigned(userB))
        XCTAssert(goal.userIsAssigned(userC))
        XCTAssert(!goal.userIsAssigned(userA))
    }
    
    func testCompletedByUser() {
        goal.addUser(userB)
        goal.addUser(userC)
        goal.completedByUser(userB)
        
        XCTAssertEqual(Set([userB]), Set(goal.getUsersWhoCompleted()))
        goal.completedByUser(userA)
        XCTAssertEqual(Set([userB]), Set(goal.getUsersWhoCompleted()))
    }
    
    func testIsCompletedByUser() {
        goal.addUser(userB)
        goal.addUser(userC)
        goal.completedByUser(userB)
        XCTAssert(goal.isCompletedByUser(userB))
        XCTAssert(!goal.isCompletedByUser(userC))
        XCTAssert(!goal.isCompletedByUser(userA))
    }
    
    func testUncompleteByUser() {
        goal.addUser(userB)
        goal.addUser(userC)
        goal.completedByUser(userB)
        goal.completedByUser(userC)
        goal.uncompleteByUser(userB)
        XCTAssertEqual([userC], goal.getUsersWhoCompleted())
        goal.uncompleteByUser(userA)
        XCTAssertEqual([userC], goal.getUsersWhoCompleted())
    }
    
    // yet to test date is correct
    func testGetCompletedDate() {
        goal.addUser(userB)
        goal.addUser(userC)
        goal.completedByUser(userB)
        XCTAssertEqual(nil, goal.getCompletedDate())
        goal.completedByUser(userC)
        let firstDate = goal.getCompletedDate()
        goal.uncompleteByUser(userB)
        goal.completedByUser(userB)
        XCTAssertEqual(goal.getCompletedDate(), goal.getCompletedDate()!.laterDate(firstDate!))
    }
    
    /// Returns true if all assigned users completed the task, false otherwise
    func testIsCompleted() {
        goal.addUser(userB)
        goal.addUser(userC)
        goal.completedByUser(userB)
        XCTAssert(!goal.isCompleted())
        goal.completedByUser(userC)
        XCTAssert(goal.isCompleted())
        
        goal.uncompleteByUser(userA)
        XCTAssert(goal.isCompleted())
        goal.uncompleteByUser(userB)
        XCTAssert(!goal.isCompleted())
    }
    
    func testGetUsersWhoCompleted() {
        goal.addUser(userA)
        goal.addUser(userB)
        goal.addUser(userC)
        
        goal.completedByUser(userA)
        XCTAssertEqual([userA], goal.getUsersWhoCompleted())
        goal.completedByUser(userB)
        XCTAssertEqual(Set([userA, userB]), Set(goal.getUsersWhoCompleted()))
        goal.completedByUser(userC)
        XCTAssertEqual(Set([userA, userB, userC]), Set(goal.getUsersWhoCompleted()))
        
        goal.uncompleteByUser(userB)
        XCTAssertEqual(Set([userA, userC]), Set(goal.getUsersWhoCompleted()))
    }
    
    func testGetNumberOfUsersAssigned() {
        goal.addUser(userA)
        XCTAssertEqual(1, goal.getNumberOfUsersAssigned())
        goal.addUser(userB)
        goal.addUser(userC)
        XCTAssertEqual(3, goal.getNumberOfUsersAssigned())
        goal.removeUser(userB)
        XCTAssertEqual(2, goal.getNumberOfUsersAssigned())
        goal.removeAllUsers()
        XCTAssertEqual(0, goal.getNumberOfUsersAssigned())
    }

}
