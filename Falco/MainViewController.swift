//
//  MainViewController.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit
import SpriteKit

class MainViewController: UIViewController, LoginDelegate {
    
    @IBOutlet weak var tabView: UIView!

    private var user = User(id: NSUUID().UUIDString, name: "MrFoo")

    private var scene: BubblesScene!

    private var goals = GoalCollection()
    private var server = Server.instance

    override func viewDidLoad() {
        super.viewDidLoad()

        if server.hasToken {
            didReceiveToken()
        }
    }

//class MainViewController: UIViewController {
//    private var goalModel = GoalCollection(goals: [])
//    private var user = User(uid: NSUUID().UUIDString, name: "MrFoo")

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        addSampleModel()
//
//        let scene = BubblesScene(size: view.bounds.size)
//        let skView = self.view as! SKView
//        skView.showsFPS = true
//        skView.showsNodeCount = true
//        skView.ignoresSiblingOrder = true
//        scene.scaleMode = .ResizeFill
//
//        for goal in goalModel.goals {
//            let goalBubble = GoalBubble(id: goal.identifier, circleOfRadius: CGFloat(goal.weight), text: goal.name)
//            let x = CGFloat(arc4random_uniform(UInt32(view.frame.maxX)))
//            let y = CGFloat(arc4random_uniform(UInt32(view.frame.maxY)))
//            goalBubble.position = CGPointMake(x, y)
//            goalBubble.name = goal.identifier
//
//            scene.addChild(goalBubble)
//        }
//        skView.presentScene(scene)
//    }

    override func viewDidAppear(animated: Bool) {
        if !server.hasToken {
            showLogin()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLogin" {
            let lvc = segue.destinationViewController as! LoginViewController
            lvc.delegate = self

        }
    }

    @IBAction func settingsTapped(sender: AnyObject) {
        showLogin()
    }

    // MARK: LoginDelegate

    func didReceiveToken() {
        authAndDownloadGoals()
    }

    // MARK: Helper methods

    private func showLogin() {
        performSegueWithIdentifier("showLogin", sender: nil)
    }

    private func authAndDownloadGoals() {
        server.auth() {
            self.server.getPersonalGoals(self.addGoalsToScene)
            self.server.getFriends(self.addSampleGroup)
        }
    }

    private func addGoalsToScene(userGoals: GoalCollection?) {
        if let userGoals = userGoals {
            goals = userGoals
            if userGoals.isEmpty {
                print("adding sample goals")
                addSampleGoals(server.user.name)
            }
            goals.sortGoalsByWeight()
            scene = BubblesScene(size: view.bounds.size, goalModel: goals)
            scene.scaleMode = .ResizeFill
            
            let skView = view as! SKView
            //        skView.showsFPS = true
            //        skView.showsNodeCount = true
            //        skView.showsPhysics = true
            skView.ignoresSiblingOrder = true
            skView.presentScene(scene)
        }
    }

    private func addSampleGoals(name: String) {
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 3
        dateComponents.day = 10

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = calendar!.dateFromComponents(dateComponents)!

        goals.updateGoal(PersonalGoal(name: "\(name)'s goal1", details: "my goal", priority: .High, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal2", details: "my goal", priority: .High, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal3", details: "my goal", priority: .Low, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal4", details: "my goal", priority: .Mid, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal5", details: "my goal", priority: .High, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal6", details: "my goal", priority: .Mid, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal7", details: "my goal", priority: .Mid, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal8", details: "my goal", priority: .Low, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal9", details: "my goal", priority: .Low, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal10", details: "my goal", priority: .Low, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal11", details: "my goal", priority: .Mid, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal12", details: "my goal", priority: .High, endTime: date))

        server.savePersonalGoals(goals)
    }

    private func addSampleGroup(friends: [User]?) {
        if friends == nil {
            return
        }

        server.getGroups() { groups in
            if groups != nil {
                print("Groups: \(groups!)")
                return
            }

            print("adding sample group")
            let user = self.server.user
            var g1 = GroupGoal(name: "my task", details: "details", endTime: NSDate())
            var g2 = GroupGoal(name: "squad goal", details: "details", endTime: NSDate())
            g1.addUser(user)
            g2.addUser(user)
            for friend in friends! {
                g2.addUser(friend)
            }
            let goals = GoalCollection(goals: [g1, g2])
            let group = Group(creator: user, name: "\(user.name)'s test group", members: friends!, goals: goals)
            self.server.saveGroup(group)
        }
    }
}

extension MainViewController {
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    private func addSampleModel() {
        // load model
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 3
        dateComponents.day = 10
        let name = "Mr Foo"

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = calendar!.dateFromComponents(dateComponents)!

        goals.updateGoal(PersonalGoal(name: "\(name)'s goal1", details: "my goal", priority: .High, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal2", details: "my goal", priority: .High, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal3", details: "my goal", priority: .Low, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal4", details: "my goal", priority: .Mid, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal5", details: "my goal", priority: .High, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal6", details: "my goal", priority: .Mid, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal7", details: "my goal", priority: .Mid, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal8", details: "my goal", priority: .Low, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal9", details: "my goal", priority: .Low, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal10", details: "my goal", priority: .Low, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal11", details: "my goal", priority: .Mid, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal12", details: "my goal", priority: .High, endTime: date))
        goals.sortGoalsByWeight()
    }
}

extension MainViewController: PresentationDelegate {
    func present(id: String, node: SKNode) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let content = storyboard.instantiateViewControllerWithIdentifier("GoalDetailViewController") as! GoalDetailViewController
        let goal = goals.getGoalWithIdentifier(id)

        content.goal = goal
        content.user = user

        content.modalPresentationStyle = .FormSheet
        content.modalTransitionStyle = .CrossDissolve
        self.presentViewController(content, animated: true, completion: nil)
    }
}