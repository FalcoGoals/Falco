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
  private var goalModel: [GoalBubble]!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    goalModel = [GoalBubble(name: "1", details: "my goal", priority: 0),
                  GoalBubble(name: "2", details: "my goal", priority: 1),
                  GoalBubble(name: "3", details: "my goal", priority: 2),
                  GoalBubble(name: "4", details: "my goal", priority: 1),
                  GoalBubble(name: "5", details: "my goal", priority: 2),
                  GoalBubble(name: "6", details: "my goal", priority: 1),
                  GoalBubble(name: "7", details: "my goal", priority: 0),
                  GoalBubble(name: "8", details: "my goal", priority: 1),
                  GoalBubble(name: "9", details: "my goal", priority: 1),
                  GoalBubble(name: "10", details: "my goal", priority: 1),
                  GoalBubble(name: "11", details: "my goal", priority: 1),
                  GoalBubble(name: "12", details: "my goal", priority: 1),
                  GoalBubble(name: "13", details: "my goal", priority: 1),
                  GoalBubble(name: "14", details: "my goal", priority: 1)]
    self.goalModel.sortInPlace {
        return $0.priority > $1.priority
    }
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
    return goalModel.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BubbleCell

    cell.layer.cornerRadius = cell.bounds.size.width / 2 // halving makes it a circle

    cell.label.text = goalModel[indexPath.item].name

    return cell
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      // adjust size of bubble
      print("size")
      let dimension = goalModel[indexPath.item].weight
      return CGSize(width: dimension, height: dimension)
  }

  func didSave(goal: GoalBubble, indexPath: NSIndexPath) {
    let itemNumber = indexPath.item
    goalModel[itemNumber] = goal
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
        detailViewController.goal = goalModel[index.item]
      }
    }
  }

  @IBAction func cancelDetail(segue: UIStoryboardSegue) {}
  @IBAction func saveDetail(segue: UIStoryboardSegue) {}
}

extension PersonalGoalViewController: GoalLayoutDelegate {
    func collectionView(collectionView: UICollectionView, diameterForGoalAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let dimension = (goalModel[indexPath.item].weight + 1) * 50
        return CGFloat(dimension)
    }
}

