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
    private var user = User(uid: NSUUID().UUIDString, name: "MrFoo")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.


        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 3
        dateComponents.day = 10

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = calendar!.dateFromComponents(dateComponents)!

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
        cell.backgroundColor = UIColor.brownColor()

        cell.label.text = goalModel.goals[indexPath.item].name
        return cell
    }


    func didSave(goal: Goal, indexPath: NSIndexPath?) {
        if let indexPath = indexPath {
            goalModel.goals[indexPath.item] = goal
        } else {
            goalModel.addGoal(goal)
        }

        goalModel.sortGoalsByWeight()
        goalsCollectionView.reloadData()
//        goalsCollectionView.performBatchUpdates({
//            //   self.goalsCollectionView.setCollectionViewLayout(self.goalsCollectionView.collectionViewLayout, animated: true)
//            self.goalsCollectionView.reloadData()
//            }, completion: { finished in
//                self.goalsCollectionView.reloadData()
//        })
        //goalsCollectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let index = goalsCollectionView.indexPathForItemAtPoint(sender!.locationInView(goalsCollectionView)) {
            let navController = segue.destinationViewController as! UINavigationController
            let detailViewController = navController.topViewController as! GoalDetailViewController
            
            detailViewController.delegate = self
            detailViewController.selectedIndexpath = index
            detailViewController.goal = goalModel.goals[index.item]
            detailViewController.user = user

        } else {
            let navController = segue.destinationViewController as! UINavigationController
            let detailViewController = navController.topViewController as! GoalDetailViewController

            detailViewController.delegate = self
            detailViewController.selectedIndexpath = nil
            detailViewController.goal = nil
            detailViewController.user = user

        }
    }

    @IBAction func GoalsTap(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("PersonalGoalToDetails", sender: sender)
    }
    @IBAction func cancelDetail(segue: UIStoryboardSegue) {}
    @IBAction func saveDetail(segue: UIStoryboardSegue) {}
}

extension PersonalGoalViewController: GoalLayoutDelegate {
    func collectionView(collectionView: UICollectionView, diameterForGoalAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let dimension = (goalModel.goals[indexPath.item].weight)
        return CGFloat(dimension)
    }
    
    func getName(indexPath: NSIndexPath) -> String {
        return goalModel.goals[indexPath.item].name
    }
}

