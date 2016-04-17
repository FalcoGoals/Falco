//
//  ModelTest_GoalCollection.swift
//  Falco
//
//  Created by Jing Yin Ong on 25/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import XCTest

class ModelTest_GoalCollection: XCTestCase {
    let localUser = User(id: "uid1", name: "ladybug")
    let userB = User(id: "uid2", name: "beetle")
    let userC = User(id: "uid3", name: "grasshopper")
    var goal1 = GroupGoal(groupId: "gid1", name: "score", details: "chips", endTime: NSDate())//(uid: "gid1", name: "score", details: "bubbletea", endTime: NSDate(), priority: .Low)
    var goal2 = GroupGoal(groupId: "gid2", name: "whistle", details: "chips", endTime: NSDate())//(uid: "gid2", name: "whistle", details: "chips", endTime: NSDate(), priority: .Mid)
    var goal3: PersonalGoal?
    var gc: GoalCollection?
    var date: NSDate?

    override func setUp() {
        super.setUp()
        goal1.addUser(localUser)
        goal1.addUser(userB)
        goal1.priority = 4
        goal2.addUser(userB)
        goal2.addUser(userC)
        goal2.priority = 7
        date = NSDate()
        goal3 = PersonalGoal(name: "score", details: "fish", endTime: NSDate())//(user: userA, uid: "pid1", name: "score", details: "fish", endTime: NSDate(), priority: .High)
        gc = GoalCollection(goals: [goal1, goal2, goal3!])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func compareGoals(a: [Goal], b: [Goal]) -> Bool {
        if a.count != b.count {
            return false
        } else {
            for goal1 in a {
                var containsGoal = false
                for goal2 in b {
                    if goal1.id == goal2.id {
                        containsGoal = true
                        break
                    }
                }
                if !containsGoal {
                    return false
                }
            }
            return true
        }
    }
    
    func compareGoalsWithOrder(a: [Goal], b: [Goal]) -> Bool {
        if a.count != b.count {
            return false
        } else {
            for i in 0..<a.count {
                if a[i].id != b[i].id {
                    return false
                }
            }
            return true
        }
    }
    
    func testAddGoal() {
        // test init with empty array
        gc = GoalCollection(goals: [])
        gc!.updateGoal(goal1)
        XCTAssert(compareGoals([goal1], b: gc!.goals))
        
        gc = GoalCollection(goals: [goal1])
        XCTAssert(compareGoals([goal1], b: gc!.goals))
        gc!.updateGoal(goal1)
        XCTAssert(compareGoals([goal1], b: gc!.goals))
        gc!.updateGoal(goal2)
        XCTAssert(compareGoals([goal1, goal2], b: gc!.goals))
    }
    
    func testGetAllGoals() {
        XCTAssert(compareGoals([goal1, goal2, goal3!], b: gc!.goals))
    }
    
    func testRemoveGoal() {
        gc!.removeGoal(goal2)
        XCTAssert(compareGoals([goal1, goal3!], b: gc!.goals))
    }
    
    func testRemoveAllGoals() {
        gc!.removeAllGoals()
        XCTAssert(gc!.isEmpty)
    }
    
    func testIsEmpty() {
        XCTAssert(!gc!.isEmpty)
        gc!.removeGoal(goal2)
        XCTAssert(!gc!.isEmpty)
        gc!.removeAllGoals()
        XCTAssert(gc!.isEmpty)
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
        XCTAssert(compareGoals([goal1,goal3!], b: gc!.getGoalsAssignedToUser(localUser)))
        XCTAssert(compareGoals([goal1,goal2, goal3!], b: gc!.getGoalsAssignedToUser(userB)))
        XCTAssert(compareGoals([goal2, goal3!], b: gc!.getGoalsAssignedToUser(userC)))
    }
    
    func testSortGoalsByPriority() {
        var array = [Goal]()
        array.append(goal2)
        array.append(goal1)
        array.append(goal3!)
        gc!.sortGoalsByPriority()
        XCTAssert(compareGoalsWithOrder(array, b: gc!.goals))
    }
    
    func testSortGoalsByEndTime() {
        goal1.endTime = NSDate(timeIntervalSinceNow: 10)
        goal2.endTime = NSDate(timeIntervalSinceNow: 11)
        goal3!.endTime = NSDate(timeIntervalSinceNow: 12)
        var array = [Goal]()
        array.append(goal1)
        array.append(goal2)
        array.append(goal3!)
        gc!.sortGoalsByEndTime()
        XCTAssert(compareGoalsWithOrder(array, b: gc!.goals))
    }
    
    func testGetGoalsBeforeEndTime() {
        XCTAssert(compareGoals([goal1, goal2], b: gc!.getGoalsBeforeEndTime(date!)))
    }
    
    func testGetCompletedGoals() {
        // complete a personal goal
        XCTAssert(compareGoals([], b: gc!.completeGoals.goals))
        gc!.markGoalComplete(goal3!, user: localUser)
        XCTAssert(compareGoals([goal3!], b: gc!.completeGoals.goals))
        
        // one user completes a group goal which is assigned to two users
        gc!.markGoalComplete(goal1, user: localUser)
        XCTAssert(compareGoals([goal3!], b: gc!.completeGoals.goals))

        // both assigned user complete the group goal
        gc!.markGoalComplete(goal1, user: userB)
        XCTAssert(compareGoals([goal3!, goal1], b: gc!.completeGoals.goals))
        
        // test unmarking -> group goal
        gc!.markGoalIncomplete(goal1, user: userC)    //unassigned user
        XCTAssert(compareGoals([goal3!, goal1], b: gc!.completeGoals.goals))
        gc!.markGoalIncomplete(goal1, user: userB)
        XCTAssert(compareGoals([goal3!], b: gc!.completeGoals.goals))

        // test unmarking -> personal goal
        gc!.markGoalIncomplete(goal3!, user: localUser)
        XCTAssert(compareGoals([], b: gc!.completeGoals.goals))
    }
    
    func testGetUncompletedGoals() {
        XCTAssert(compareGoals([goal3!, goal1, goal2], b: gc!.incompleteGoals.goals))
        gc!.markGoalComplete(goal3!, user: localUser)
        XCTAssert(compareGoals([goal1, goal2], b: gc!.incompleteGoals.goals))
        
        gc!.markGoalComplete(goal1, user: localUser)
        XCTAssert(compareGoals([goal1, goal2], b: gc!.incompleteGoals.goals))
        gc!.markGoalComplete(goal1, user: userC)  //userC is not assigned to goal1
        XCTAssert(compareGoals([goal1, goal2], b: gc!.incompleteGoals.goals))
        gc!.markGoalComplete(goal1, user: userB)
        XCTAssert(compareGoals([goal2], b: gc!.incompleteGoals.goals))
        
        // test unmarking -> group goal
        gc!.markGoalIncomplete(goal1, user: userC)    //unassigned user
        XCTAssert(compareGoals([goal2], b: gc!.incompleteGoals.goals))
        gc!.markGoalIncomplete(goal1, user: userB)
        XCTAssert(compareGoals([goal1, goal2], b: gc!.incompleteGoals.goals))
        
        // test unmarking -> personal goal
        gc!.markGoalIncomplete(goal3!, user: localUser)
        XCTAssert(compareGoals([goal1, goal2, goal3!], b: gc!.incompleteGoals.goals))
    }
    
    func testGetGoalsWithName() {
        XCTAssert(compareGoals([], b: gc!.getGoalsWithName("blah")))
        XCTAssert(compareGoals([goal2], b: gc!.getGoalsWithName("whistle")))
        XCTAssert(compareGoals([goal1, goal3!], b: gc!.getGoalsWithName("score")))
    }
    
    func testGetGoalWithIdentifier() {
        if let goal = gc!.getGoalWithIdentifier("blah") {
            XCTFail()
        }
        XCTAssert(compareGoals([goal2], b: [gc!.getGoalWithIdentifier(goal2.id)!]))
        XCTAssert(compareGoals([goal3!], b: [gc!.getGoalWithIdentifier((goal3?.id)!)!]))
    }

}