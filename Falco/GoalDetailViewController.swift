//
//  GoalDetailViewController.swift
//  Falco
//
//  Created by Gerald on 22/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

protocol GoalDetailDelegate {
  func didSave(detailController: GoalDetailViewController, indexPath: NSIndexPath)
}

class GoalDetailViewController: UIViewController {
  var name: String!
  var details: String!
  var deadline: NSDate!
  var priority: Int!
  var selectedIndexpath: NSIndexPath!
  var delegate: GoalDetailDelegate!

  @IBOutlet weak var navTitle: UINavigationItem!
  @IBOutlet weak var detailLabel: UITextField!
  @IBOutlet weak var deadlineField: UILabel!
  @IBOutlet weak var priorityControl: UISegmentedControl!

  override func viewDidLoad() {
    super.viewDidLoad()

    navTitle.title = name
    detailLabel.text = details
    priorityControl.selectedSegmentIndex = priority

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: Action
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "saveDetailSegue") {
      save()
    }
  }
  func save() {
    details = detailLabel.text
    priority = priorityControl.selectedSegmentIndex

    delegate.didSave(self, indexPath: selectedIndexpath)
  }
}
