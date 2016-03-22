//
//  GoalDetailViewController.swift
//  Falco
//
//  Created by Gerald on 22/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GoalDetailViewController: UIViewController {
  @IBOutlet weak var label: UILabel!
  var goalDetail: String? = nil

  override func viewDidLoad() {
    super.viewDidLoad()

    label.text = goalDetail
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}
