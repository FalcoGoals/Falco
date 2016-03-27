//
//  GoalDetailViewController.swift
//  Falco
//
//  Created by Gerald on 22/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

protocol GoalDetailDelegate {
  func didSave(goal: Goal, indexPath: NSIndexPath)
}

class GoalDetailViewController: UIViewController {
  var goal: Goal!
  var selectedIndexpath: NSIndexPath!
  var delegate: GoalDetailDelegate!

  @IBOutlet weak var navTitle: UINavigationItem!
  @IBOutlet weak var detailLabel: UITextField!
  @IBOutlet weak var deadlineField: UILabel!
  @IBOutlet weak var priorityControl: UISegmentedControl!

  override func viewDidLoad() {
    super.viewDidLoad()

    navTitle.title = goal.name
    detailLabel.text = goal.details
    deadlineField.text = getDateString(goal.endTime)
    priorityControl.selectedSegmentIndex = goal.priority.rawValue

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
    goal.details = detailLabel.text!
    goal.priority = PRIORITY_TYPE(rawValue: priorityControl.selectedSegmentIndex)!

    delegate.didSave(goal, indexPath: selectedIndexpath)
  }

  /// Uses medium style date
  private func getDateString(date: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .MediumStyle
    dateFormatter.locale = NSLocale.currentLocale()
    return dateFormatter.stringFromDate(goal.endTime)
  }
}
