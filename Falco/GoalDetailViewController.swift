//
//  GoalDetailViewController.swift
//  Falco
//
//  Created by Gerald on 22/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GoalDetailViewController: UIViewController {
  var name: String!
  var detail: String!
  var deadline: NSDate!
  var priority: Int!

  @IBOutlet weak var navTitle: UINavigationItem!
  @IBOutlet weak var detailLabel: UITextField!
  @IBOutlet weak var deadlineField: UILabel!
  @IBOutlet weak var priorityControl: UISegmentedControl!

  override func viewDidLoad() {
    super.viewDidLoad()

    navTitle.title = name
    detailLabel.text = detail
    priorityControl.selectedSegmentIndex = priority

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}
