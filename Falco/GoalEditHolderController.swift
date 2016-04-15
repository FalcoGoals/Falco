//
//  GoalEditHolderController.swift
//  Falco
//
//  Created by Gerald on 15/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

protocol Savable {
    func didSave(goal: Goal)
}

class GoalEditHolderController: UIViewController, GoalEditDelegate {
    var goal: Goal!
    var group: Group?
    var members: [User]?

    var saveDelegate: Savable!
    var goalEditController: GoalEditViewController!

    @IBOutlet weak var navbar: UINavigationItem!

    override func viewDidLoad() {
        navbar.title = goal.name
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.goalEditSegue {
            goalEditController = segue.destinationViewController as! GoalEditViewController
            goalEditController.delegate = self
        }
    }

    @IBAction func saveDetails(sender: UIBarButtonItem) {
        goal.name = goalEditController.nameField.text!
        goal.details = goalEditController.detailsField.text!
        goal.priority = goalEditController.priorityControl.selectedSegmentIndex
        goal.endTime = goalEditController.datePicker.date

        saveDelegate.didSave(goal)
        dismissViewControllerAnimated(true, completion: nil)
    }
}