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

class GoalDetailViewController: UITableViewController {
    @IBOutlet weak var detailsField: UITextField!
    @IBOutlet weak var deadlineField: UITableViewCell!
    @IBOutlet weak var priorityControl: UISegmentedControl!

  var goal: Goal!
  var selectedIndexpath: NSIndexPath!
  var delegate: GoalDetailDelegate!

  override func viewDidLoad() {
    super.viewDidLoad()

    title = goal.name
    detailsField.text = goal.details
    deadlineField.textLabel?.text = getDateString(goal.endTime)
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
    goal.details = detailsField.text!
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
