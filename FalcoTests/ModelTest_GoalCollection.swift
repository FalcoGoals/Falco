//
//  ModelTest_GoalCollection.swift
//  Falco
//
//  Created by Jing Yin Ong on 25/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import XCTest

class ModelTest_GoalCollection: XCTestCase {
    let userA = User(uid: "uid1", name: "ladybug")
    let userB = User(uid: "uid2", name: "beetle")
    let userC = User(uid: "uid3", name: "grasshopper")
    let goal1 = GroupGoal(uid: "gid1", name: "score", endTime: NSDate(), priority: .low)
    let goal2 = GroupGoal(uid: "gid2", name: "whistle", endTime: NSDate(), priority: .mid)
    var goal3: PersonalGoal?
    var gc: GoalCollection?
    var date: NSDate?

    override func setUp() {
        super.setUp()
        goal1.addUser(userA)
        goal1.addUser(userB)
        goal2.addUser(userB)
        goal2.addUser(userC)
        date = NSDate()
        goal3 = PersonalGoal(user: userA, uid: "pid1", name: "score", endTime: NSDate(), priority: .high)
        gc = GoalCollection(goals: [goal1, goal2, goal3!])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddGoal() {
        // test init with empty array
        gc = GoalCollection(goals: [])
        gc!.addGoal(goal1)
        XCTAssertEqual([goal1], gc!.goals)
        
        gc = GoalCollection(goals: [goal1])
        XCTAssertEqual([goal1], gc!.goals)
        gc!.addGoal(goal1)
        XCTAssertEqual([goal1], gc!.goals)
        gc!.addGoal(goal2)
        XCTAssertEqual(Set([goal1, goal2]), Set(gc!.goals))
    }
    
    func testGetAllGoals() {
        XCTAssertEqual(Set(arrayLiteral: goal1, goal2, goal3!), Set(gc!.goals))
    }
    
    func testRemoveGoal() {
        gc!.removeGoal(goal2)
        XCTAssertEqual(Set(arrayLiteral: goal1, goal3!), Set(gc!.goals))
    }
    
    func testRemoveAllGoals() {
        gc!.removeAllGoals()
        XCTAssert(gc!.isEmpty())
    }
    
    func testIsEmpty() {
        XCTAssert(!gc!.isEmpty())
        gc!.removeGoal(goal2)
        XCTAssert(!gc!.isEmpty())
        gc!.removeAllGoals()
        XCTAssert(gc!.isEmpty())
    }
    
    func testContainsGoal() {
        XCTAssert(gc!.containsGoal(goal1))
        XCTAssert(gc!.containsGoal(goal2))
        XCTAssert(gc!.containsGoal(goal3!))
        gc!.removeGoal(goal1)
        XCTAssert(!gc!.containsGoal(goal1))
        XCTAssert(gc!.containsGoal(goal2))
        XCTAssert(gc!.containsGoal(goal3!))
    }
    
    func testGetGoalsAssignedToUser() {
        XCTAssertEqual(Set(arrayLiteral: goal1, goal3!), Set(gc!.getGoalsAssignedToUser(userA)))
        XCTAssertEqual(Set(arrayLiteral: goal1, goal2), Set(gc!.getGoalsAssignedToUser(userB)))
        XCTAssertEqual(Set(arrayLiteral: goal2), Set(gc!.getGoalsAssignedToUser(userC)))
    }
    
    func testSortGoalsByPriority() {
        var array = [Goal]()
        array.append(goal3!)
        array.append(goal2)
        array.append(goal1)
        XCTAssertEqual(array, gc!.sortGoalsByPriority())
    }
    
    func testSortGoalsByEndTime() {
        goal1.setEndTime(NSDate(timeIntervalSinceNow: 10))
        goal2.setEndTime(NSDate(timeIntervalSinceNow: 11))
        goal3!.setEndTime(NSDate(timeIntervalSinceNow: 12))
        var array = [Goal]()
        array.append(goal1)
        array.append(goal2)
        array.append(goal3!)
        XCTAssertEqual(array, gc!.sortGoalsByEndTime())
    }
    
    func testGetGoalsBeforeEndTime() {
        XCTAssertEqual(Set([goal1, goal2]), Set(gc!.getGoalsBeforeEndTime(date!)))
    }
    
    func testGetCompletedGoals() {
        XCTAssertEqual([], gc!.getCompletedGoals())
        gc!.markGoalAsComplete(goal3!, user: goal3!.user)
        XCTAssertEqual([goal3!], gc!.getCompletedGoals())
        
        gc!.markGoalAsComplete(goal1, user: userA)
        XCTAssertEqual([goal3!], gc!.getCompletedGoals())
        gc!.markGoalAsComplete(goal1, user: userC)  //userC is not assigned to goal1
        XCTAssertEqual([goal3!], gc!.getCompletedGoals())
        gc!.markGoalAsComplete(goal1, user: userB)
        XCTAssertEqual(Set([goal3!, goal1]), Set(gc!.getCompletedGoals()))
        
        // test unmarking -> group goal
        gc!.unmarkGoalAsComplete(goal1, user: userC)    //unassigned user
        XCTAssertEqual(Set([goal3!, goal1]), Set(gc!.getCompletedGoals()))
        gc!.unmarkGoalAsComplete(goal1, user: userB)
        XCTAssertEqual([goal3!], gc!.getCompletedGoals())

        gc!.unmarkGoalAsComplete(goal3!, user: userC)   //unassigned user
        XCTAssertEqual([goal3!], gc!.getCompletedGoals())
        gc!.unmarkGoalAsComplete(goal3!, user: goal3!.user)
        XCTAssertEqual([], gc!.getCompletedGoals())
    }
    
    func testGetUncompletedGoals() {
        XCTAssertEqual(Set([goal1, goal2, goal3!]), Set(gc!.getUncompletedGoals()))
        gc!.markGoalAsComplete(goal3!, user: goal3!.user)
        XCTAssertEqual(Set([goal1, goal2]), Set(gc!.getUncompletedGoals()))
        
        gc!.markGoalAsComplete(goal1, user: userA)
        XCTAssertEqual(Set([goal1, goal2]), Set(gc!.getUncompletedGoals()))
        gc!.markGoalAsComplete(goal1, user: userC)  //userC is not assigned to goal1
        XCTAssertEqual(Set([goal1, goal2]), Set(gc!.getUncompletedGoals()))
        gc!.markGoalAsComplete(goal1, user: userB)
        XCTAssertEqual(Set([goal2]), Set(gc!.getUncompletedGoals()))
        
        // test unmarking -> group goal
        gc!.unmarkGoalAsComplete(goal1, user: userC)    //unassigned user
        XCTAssertEqual(Set([goal2]), Set(gc!.getUncompletedGoals()))
        gc!.unmarkGoalAsComplete(goal1, user: userB)
        XCTAssertEqual(Set([goal1, goal2]), Set(gc!.getUncompletedGoals()))
        
        // test unmarking -> personal goal
        gc!.unmarkGoalAsComplete(goal3!, user: userC)   //unassigned user
        XCTAssertEqual(Set([goal1, goal2]), Set(gc!.getUncompletedGoals()))
        gc!.unmarkGoalAsComplete(goal3!, user: goal3!.user)
        XCTAssertEqual(Set([goal1, goal2, goal3!]), Set(gc!.getUncompletedGoals()))
    }
    
    func testGetGoalsWithName() {
        XCTAssertEqual([], gc!.getGoalsWithName("blah"))
        XCTAssertEqual([goal2], gc!.getGoalsWithName("whistle"))
        XCTAssertEqual(Set([goal1, goal3!]), Set(gc!.getGoalsWithName("score")))
    }
    
    func testGetGoalWithIdentifier() {
        XCTAssertEqual(nil, gc!.getGoalWithIdentifier("blah"))
        XCTAssertEqual(goal2, gc!.getGoalWithIdentifier("gid2"))
        XCTAssertEqual(goal3!, gc!.getGoalWithIdentifier("pid1"))
    }

}
