//
//  MainViewController.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit
import SpriteKit

class MainViewController: UIViewController, LoginDelegate, UIPopoverPresentationControllerDelegate {
    
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

        scene = BubblesScene(size: view.bounds.size)
        scene.scaleMode = .ResizeFill

        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
        skView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainViewController.bubbleTapped(_:))))
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

        } else if segue.identifier == "showDetailView" {
            let dvc = segue.destinationViewController as! GoalDetailViewController

            let location = sender!.locationInView(sender!.view)
            let touchLocation = scene.convertPointFromView(location)
            var node = scene.nodeAtPoint(touchLocation)
            while !(node is GoalBubble) && node.parent != nil {
                if let parent = node.parent {
                    node = parent
                } else {
                    break
                }
            }

            dvc.popoverPresentationController!.sourceView = sender!.view
            if let node = node as? GoalBubble {
                dvc.goal = goals.getGoalWithIdentifier(node.id)
                dvc.popoverPresentationController!.sourceRect = CGRect(origin: location, size: node.frame.size)
            } else {
                dvc.goal = nil
                dvc.popoverPresentationController!.sourceRect.offsetInPlace(dx: location.x, dy: location.y)
            }
            dvc.delegate = self
            dvc.popoverPresentationController!.delegate = self
            pauseScene()
        }
    }

    func bubbleTapped(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("showDetailView", sender: sender)
    }

    @IBAction func settingsTapped(sender: AnyObject) {
        showLogin()
    }

    // MARK: LoginDelegate

    func didReceiveToken() {
        authAndDownloadGoals()
    }

    // MARK: UIPopoverPresentationControllerDelegate

    func popoverPresentationControllerDidDismissPopover(_: UIPopoverPresentationController) {
        playScene()
    }

    // MARK: Segue

    @IBAction func cancelGoalEdit(segue: UIStoryboardSegue) { playScene() }
    @IBAction func saveGoalEdit(segue: UIStoryboardSegue) { playScene() }

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
            scene.addGoals(goals)
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

    private func pauseScene() {
        self.scene.view?.paused = true
    }

    private func playScene() {
        self.scene.view?.paused = false
    }
}

extension MainViewController {
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

//extension MainViewController: PresentationDelegate {
//    func present(id: String?) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let content = storyboard.instantiateViewControllerWithIdentifier("GoalDetailViewController") as! GoalDetailViewController
//
//        let goal: Goal?
//        if let id = id {
//            goal = goals.getGoalWithIdentifier(id)
//        } else {
//            goal = nil
//        }
//
//        content.delegate = self
//        content.goal = goal
//        content.user = user
//
//        content.modalPresentationStyle = .FormSheet
//        content.modalTransitionStyle = .CrossDissolve
//        self.presentViewController(content, animated: true, completion: nil)
//        self.scene.view?.paused = true
//    }
//}

extension MainViewController: GoalDetailDelegate {
    func didSave(goal: Goal) {
        goals.updateGoal(goal)
        scene.updateGoal(goal)
        if let goal = goal as? PersonalGoal {
            server.savePersonalGoal(goal)
        }
    }
}