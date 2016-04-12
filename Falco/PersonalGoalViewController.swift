//
//  ViewController.swift
//  Falco
//
//  Created by Gerald on 15/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class PersonalGoalViewController: UIViewController, GoalEditDelegate, LoginDelegate {
    private let reuseIdentifier = "bubble"

    @IBOutlet var collectionView: UICollectionView!

    private var goals = GoalCollection()
    private var server = Server.instance

    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()

        if let layout = collectionView.collectionViewLayout as? GoalsLayout {
            layout.delegate = self
        }

        if server.hasToken {
            didReceiveToken()
        }
    }

    override func viewDidAppear(animated: Bool) {
        if !server.hasToken {
            performSegueWithIdentifier("showLogin", sender: nil)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLogin" {
            let lvc = segue.destinationViewController as! LoginViewController
            lvc.delegate = self

        } else if segue.identifier == "showDetailView" {
            let nc = segue.destinationViewController as! UINavigationController
            let dvc = nc.topViewController as! GoalEditViewController
            let indexPath = collectionView.indexPathForItemAtPoint(sender!.locationInView(collectionView))

            dvc.delegate = self
            nc.popoverPresentationController!.sourceView = collectionView
            if let indexPath = indexPath {
                dvc.goal = goals.goals[indexPath.item]
                nc.popoverPresentationController!.sourceRect = collectionView.cellForItemAtIndexPath(indexPath)!.frame
            } else {
                let location = sender!.locationInView(collectionView)
                nc.popoverPresentationController!.sourceRect.offsetInPlace(dx: location.x, dy: location.y)
            }
        }
    }

    // MARK: IB actions

    @IBAction func cancelDetail(segue: UIStoryboardSegue) {}

    @IBAction func saveDetail(segue: UIStoryboardSegue) {}

    // MARK: LoginDelegate
    func didReceiveToken() {
        authAndDownloadGoals()
    }

    // MARK: GoalDetailDelegate
    func didSave(goal: Goal) {
        goals.updateGoal(goal)
        goals.sortGoalsByWeight()
        collectionView.reloadData()

        if let goal = goal as? PersonalGoal {
            server.savePersonalGoal(goal)
        }
    }

    // MARK: Helper methods

    private func authAndDownloadGoals() {
        server.auth() {
            self.server.registerPersonalGoalsCallback(self.updateModelWith)
            self.server.getFriends(self.addSampleGroup)
        }
    }

    private func updateModelWith(userGoals: GoalCollection?) {
        if let userGoals = userGoals {
            goals = userGoals
            if userGoals.isEmpty {
                print("adding sample goals")
                addSampleGoals(server.user.name)
            }
            goals.sortGoalsByWeight()
            collectionView.reloadData()
        }
    }

    private func addSampleGoals(name: String) {
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 3
        dateComponents.day = 10

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = calendar!.dateFromComponents(dateComponents)!

        goals.updateGoal(PersonalGoal(name: "\(name)'s goal1", details: "my goal", priority: 2, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal2", details: "my goal", priority: 2, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal3", details: "my goal", priority: 0, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal4", details: "my goal", priority: 1, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal5", details: "my goal", priority: 2, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal6", details: "my goal", priority: 1, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal7", details: "my goal", priority: 1, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal8", details: "my goal", priority: 0, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal9", details: "my goal", priority: 0, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal10", details: "my goal", priority: 0, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal11", details: "my goal", priority: 1, endTime: date))
        goals.updateGoal(PersonalGoal(name: "\(name)'s goal12", details: "my goal", priority: 2, endTime: date))

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

/**extension PersonalGoalViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goals.goals.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BubbleCell

        cell.layer.cornerRadius = cell.bounds.size.width / 2 // halving makes it a circle
        cell.backgroundColor = UIColor.brownColor()

        cell.label.text = goals.goals[indexPath.item].name
        return cell
    }
    
    
    /// testing groups view
    @IBAction func backButtonSelected(sender: AnyObject) {
        let menuViewController = self.storyboard!.instantiateViewControllerWithIdentifier("addGroup")
        menuViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(menuViewController, animated: true, completion: nil)
    }
    
    @IBAction func groupButtonSelected(sender: AnyObject) {
        let menuViewController = self.storyboard!.instantiateViewControllerWithIdentifier("groupsView")
        menuViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(menuViewController, animated: true, completion: nil)
    }
    
}*/

extension PersonalGoalViewController: GoalLayoutDelegate {
    func collectionView(collectionView: UICollectionView, diameterForGoalAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let dimension = (goals.goals[indexPath.item].weight)
        return CGFloat(dimension)
    }

    func getName(indexPath: NSIndexPath) -> String {
        return goals.goals[indexPath.item].name
    }
}
