//
//  ViewController.swift
//  Falco
//
//  Created by Gerald on 15/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class PersonalGoalViewController: UIViewController, UICollectionViewDataSource, GoalDetailDelegate {
    @IBOutlet weak var goalsCollectionView: UICollectionView!

    private let reuseIdentifier = "bubble"
    private var goalModel = GoalCollection(goals: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.


        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 3
        dateComponents.day = 10

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = calendar!.dateFromComponents(dateComponents)!
        let user = User(uid: NSUUID().UUIDString, name: "MrFoo")

        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal1", details: "my goal", endTime: date, priority: PRIORITY_TYPE.high))
        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal2", details: "my goal", endTime: date, priority: PRIORITY_TYPE.high))
        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal3", details: "my goal", endTime: date, priority: PRIORITY_TYPE.low))
        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal4", details: "my goal", endTime: date, priority: PRIORITY_TYPE.mid))
        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal5", details: "my goal", endTime: date, priority: PRIORITY_TYPE.high))
        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal6", details: "my goal", endTime: date, priority: PRIORITY_TYPE.mid))
        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal7", details: "my goal", endTime: date, priority: PRIORITY_TYPE.mid))
        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal8", details: "my goal", endTime: date, priority: PRIORITY_TYPE.low))
        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal9", details: "my goal", endTime: date, priority: PRIORITY_TYPE.low))
        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal10", details: "my goal", endTime: date, priority: PRIORITY_TYPE.low))
        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal11", details: "my goal", endTime: date, priority: PRIORITY_TYPE.mid))
        goalModel.addGoal(PersonalGoal(user: user, uid: NSUUID().UUIDString, name: "goal12", details: "my goal", endTime: date, priority: PRIORITY_TYPE.high))

        goalModel.sortGoalsByWeight()
        
        if let layout = goalsCollectionView?.collectionViewLayout as? GoalsLayout {
            layout.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goalModel.goals.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BubbleCell

        cell.layer.cornerRadius = cell.bounds.size.width / 2 // halving makes it a circle

        cell.label.text = goalModel.goals[indexPath.item].name

        return cell
    }

    func didSave(goal: Goal, indexPath: NSIndexPath) {
        goalModel.goals[indexPath.item] = goal
        goalsCollectionView.reloadData()
    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "PersonalGoalToDetails") {
            let navController = segue.destinationViewController as! UINavigationController
            let detailViewController = navController.topViewController as! GoalDetailViewController

            let cell = sender as! UICollectionViewCell

            if let index = goalsCollectionView.indexPathForCell(cell) {
                detailViewController.delegate = self
                detailViewController.selectedIndexpath = index
                detailViewController.goal = goalModel.goals[index.item]
            }
        }
    }

    @IBAction func cancelDetail(segue: UIStoryboardSegue) {}
    @IBAction func saveDetail(segue: UIStoryboardSegue) {}
}

extension PersonalGoalViewController: GoalLayoutDelegate {
    func collectionView(collectionView: UICollectionView, diameterForGoalAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let dimension = (goalModel.goals[indexPath.item].weight)
        return CGFloat(dimension)
    }
}

