//
//  MainViewController.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit
import SpriteKit

class MainViewController: UIViewController {
    
    private var goalModel = GoalCollection(goals: [])
    private var user = User(uid: NSUUID().UUIDString, name: "MrFoo")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let size = CGSize(width: view.bounds.size.width, height: getHeight())
        let scene = BubblesScene(size: size, goalModel: goalModel)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = false
        scene.scaleMode = .ResizeFill
        skView.showsPhysics = true
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func getHeight() -> CGFloat {
        var height = CGFloat(0)
        for goal in goalModel.goals {
            height += CGFloat(goal.weight)
        }
        return height
    }
}
