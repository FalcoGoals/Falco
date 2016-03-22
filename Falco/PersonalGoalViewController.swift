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
    goalModel = [GoalBubble(name: "1", weight: 100), GoalBubble(name: "2", weight: 200),
                 GoalBubble(name: "3", weight: 300), GoalBubble(name: "4", weight: 10),
                 GoalBubble(name: "5", weight: 20), GoalBubble(name: "6", weight: 50),
                 GoalBubble(name: "7", weight: 100), GoalBubble(name: "8", weight: 121),
                 GoalBubble(name: "9", weight: 17), GoalBubble(name: "10", weight: 100)]
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
        detailViewController.goalDetail = goalModel[index.item].name
      }

      detailViewController.modalPresentationStyle = .OverCurrentContext
      detailViewController.modalTransitionStyle = .CrossDissolve
    }
  }
}

