//
//  BubblesScene.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import SpriteKit

class BubblesScene: SKScene {
    private var goalModel = GoalCollection(goals: [])
    private var user = User(uid: NSUUID().UUIDString, name: "MrFoo")

    override init(size: CGSize) {
        super.init(size: size)

        // load model
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 3
        dateComponents.day = 10

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = calendar!.dateFromComponents(dateComponents)!

        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal1", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal2", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal3", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal4", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal5", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal6", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal7", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal8", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal9", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal10", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal11", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal12", details: "my goal", endTime: date, priority: .High))
        goalModel.sortGoalsByWeight()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsWorld.gravity = CGVectorMake(0, 4)

        for goal in goalModel.goals {
            let goal = GoalBubble(circleOfRadius: CGFloat(goal.weight), text: goal.name)
            let x = CGFloat(arc4random_uniform(UInt32(frame.maxX)))
            let y = CGFloat(arc4random_uniform(UInt32(frame.maxY)))
            goal.position = CGPointMake(x, y)
            addChild(goal)
        }
    }
}
