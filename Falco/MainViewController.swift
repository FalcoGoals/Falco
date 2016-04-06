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
        
        goalModel.updateGoal(PersonalGoal(name: "goal1", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(name: "goal2", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(name: "goal3", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal4", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal5", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(name: "goal6", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal7", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal8", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal9", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal10", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal11", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal12", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(name: "goal13", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(name: "goal14", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(name: "goal15", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal16", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal17", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(name: "goal18", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal19", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal20", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal21", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal22", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal23", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal23", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(name: "goal24", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(name: "goal25", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(name: "goal26", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal27", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal28", details: "my goal", endTime: date, priority: .High))
        goalModel.updateGoal(PersonalGoal(name: "goal29", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal30", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal31", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal32", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal33", details: "my goal", endTime: date, priority: .Low))
        goalModel.updateGoal(PersonalGoal(name: "goal34", details: "my goal", endTime: date, priority: .Mid))
        goalModel.updateGoal(PersonalGoal(name: "goal35", details: "my goal", endTime: date, priority: .High))
        goalModel.sortGoalsByWeight()
        
        let scene = BubblesScene(size: view.bounds.size, goalModel: goalModel)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.showsPhysics = true
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
