//
//  ViewController.swift
//  Pegasus
//
//  Created by Gerald on 15/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class PersonalGoalViewController: UIViewController {
  @IBOutlet weak var goalsCollectionView: UICollectionView!

  private let reuseIdentifier = "bubble"
  private var goalModel: [GoalBubble]!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    goalModel = [GoalBubble(name: "1", details: "my goal", priority: 100),
                  GoalBubble(name: "2", details: "my goal", priority: 200),
                  GoalBubble(name: "3", details: "my goal", priority: 300),
                  GoalBubble(name: "4", details: "my goal", priority: 10),
                  GoalBubble(name: "5", details: "my goal", priority: 20),
                  GoalBubble(name: "6", details: "my goal", priority: 50),
                  GoalBubble(name: "7", details: "my goal", priority: 100),
                  GoalBubble(name: "8", details: "my goal", priority: 121),
                  GoalBubble(name: "9", details: "my goal", priority: 17),
                  GoalBubble(name: "10", details: "my goal", priority: 100)]
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
      let dimension = goalModel[indexPath.item].weight
      return CGSize(width: dimension, height: dimension)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "PersonalGoalToDetails") {
      let detailViewController = segue.destinationViewController as! GoalDetailViewController
      let cell = sender as! UICollectionViewCell

      if let index = goalsCollectionView.indexPathForCell(cell) {
        detailViewController.goalDetail = goalModel[index.item].details

        detailViewController.modalPresentationStyle = .FormSheet
        detailViewController.modalTransitionStyle = .CrossDissolve
      }
    }
  }
}

