//
//  ViewController.swift
//  Falco
//
//  Created by Gerald on 15/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class PersonalGoalViewController: UIViewController, GoalDetailDelegate, LoginDelegate {
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
            let dvc = nc.topViewController as! GoalDetailViewController
            let indexPath = collectionView.indexPathForItemAtPoint(sender!.locationInView(collectionView))

            dvc.delegate = self
            dvc.selectedIndexpath = indexPath
            if let index = indexPath?.item {
                dvc.goal = goals.goals[index]
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
    func didSave(goal: Goal, indexPath: NSIndexPath?) {
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
        }
    }

    private func updateModelWith(userGoals: GoalCollection?) {
        if let userGoals = userGoals {
            goals = userGoals
            if userGoals.isEmpty() {
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
}

extension PersonalGoalViewController: UICollectionViewDataSource {
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
}

extension PersonalGoalViewController: GoalLayoutDelegate {
    func collectionView(collectionView: UICollectionView, diameterForGoalAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let dimension = (goals.goals[indexPath.item].weight)
        return CGFloat(dimension)
    }

    func getName(indexPath: NSIndexPath) -> String {
        return goals.goals[indexPath.item].name
    }
}
