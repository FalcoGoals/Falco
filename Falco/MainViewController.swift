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

    private var goalModel = GoalCollection()
    private var server = Server.instance
    
    private var circlePosition = [[Int]]()
    private var lowestY = 0
    private var offset = CGFloat(100)

    override func viewDidLoad() {
        super.viewDidLoad()

        if server.hasToken {
            didReceiveToken()
        }
        
        scene = BubblesScene(size: view.bounds.size)
        scene.scaleMode = .ResizeFill
        
        let skView = view as! SKView
        //        skView.showsFPS = true
        //        skView.showsNodeCount = true
        //        skView.showsPhysics = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }

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
            goalModel = userGoals
            if userGoals.isEmpty {
                print("adding sample goals")
                addSampleGoals(server.user.name)
            }
            goalModel.sortGoalsByWeight()
            
            for goal in goalModel.goals {
                let weight = goal.weight
                let (x,y) = calculateNextPosition(weight)
                let goalBubble = GoalBubble(id: goal.id,circleOfRadius: CGFloat(weight)/2, text: goal.name)
                goalBubble.delegate = self
                if (y - weight/2 < lowestY) {
                    lowestY = y - weight/2
                }
                circlePosition.append([x, y, weight])
                goalBubble.position = CGPointMake(CGFloat(x), CGFloat(y) - offset)
                offset += 50
                scene.addGoal(goalBubble)
            }
        }
    }

    private func addSampleGoals(name: String) {
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 3
        dateComponents.day = 10

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = calendar!.dateFromComponents(dateComponents)!

        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal1", details: "my goal", priority: .High, endTime: date))
        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal2", details: "my goal", priority: .High, endTime: date))
        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal3", details: "my goal", priority: .Low, endTime: date))
        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal4", details: "my goal", priority: .Mid, endTime: date))
        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal5", details: "my goal", priority: .High, endTime: date))
        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal6", details: "my goal", priority: .Mid, endTime: date))
        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal7", details: "my goal", priority: .Mid, endTime: date))
        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal8", details: "my goal", priority: .Low, endTime: date))
        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal9", details: "my goal", priority: .Low, endTime: date))
        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal10", details: "my goal", priority: .Low, endTime: date))
        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal11", details: "my goal", priority: .Mid, endTime: date))
        goalModel.updateGoal(PersonalGoal(name: "\(name)'s goal12", details: "my goal", priority: .High, endTime: date))

        server.savePersonalGoals(goalModel)
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
    
    private func calculateNextPosition(diameter: Int) -> (Int, Int){
        var xValue = 0
        var lowestYValue = lowestY
        let maxXValue = Int(view.bounds.size.width) - diameter
        
        
        for currX in 0..<maxXValue {
            var currY = lowestYValue
            var intersection = false
            while (currY < 0) {
                for circle in circlePosition {
                    if (circleIntersection(circle[0], y1: circle[1],
                        r1: circle[2]/2, x2: currX+diameter/2, y2: currY+diameter/2, r2: diameter/2)) {
                        intersection = true
                        break
                    }
                }
                if (intersection) {
                    break
                } else {
                    currY += 1
                }
            }
            if (currY > lowestYValue) {
                xValue = currX
                lowestYValue = currY
            }
        }
        
        return (xValue + diameter/2, lowestYValue - diameter/2)
    }
    
    private func circleIntersection(x1: Int, y1: Int, r1: Int, x2: Int, y2: Int, r2: Int) -> Bool {
        let dx = Double(x1) - Double(x2);
        let dy = Double(y1) - Double(y2);
        let distance = sqrt(dx * dx + dy * dy);
        
        if distance <= (Double(r1) + Double(r2)) {
            return true
        } else {
            return false
        }
    }
}

extension MainViewController {
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension MainViewController: PresentationDelegate {
    func present(id: String, node: SKNode) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let content = storyboard.instantiateViewControllerWithIdentifier("GoalDetailViewController") as! GoalDetailViewController
        let goal = goalModel.getGoalWithIdentifier(id)

        content.goal = goal
        content.user = user

        content.modalPresentationStyle = .FormSheet
        content.modalTransitionStyle = .CrossDissolve
        self.presentViewController(content, animated: true, completion: nil)
    }
}