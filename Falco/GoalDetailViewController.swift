//
//  GoalDetailViewController.swift
//  Falco
//
//  Created by Gerald on 22/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GoalDetailViewController: UIViewController {
  var name: String? = nil
  var detail: String? = nil
  var deadline: NSDate? = nil
  var priority: Int? = nil

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var detailLabel: UITextField!
  @IBOutlet weak var deadlineField: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    nameLabel.text = name
    detailLabel.text = detail
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}
