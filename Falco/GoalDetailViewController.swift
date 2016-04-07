//
//  GoalDetailViewController.swift
//  Falco
//
//  Created by Gerald on 22/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

protocol GoalDetailDelegate {
    func didSave(goal: Goal, indexPath: NSIndexPath?)
}

class GoalDetailViewController: UITableViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var detailsField: UITextField!
    @IBOutlet weak var deadlineField: UITableViewCell!
    @IBOutlet weak var priorityControl: UISegmentedControl!

    var delegate: GoalDetailDelegate!

    var goal: Goal!
    var selectedDate: NSDate!
    var selectedIndexpath: NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        if goal == nil {
            goal = PersonalGoal(name: "New Goal", details: "", priority: .Mid, endTime: NSDate())
        }

        nameField.text = goal.name
        detailsField.text = goal.details
        selectedDate = goal.endTime
        deadlineField.textLabel?.text = getDateString(selectedDate)
        deadlineField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GoalDetailViewController.selectDate(_:))))
        priorityControl.selectedSegmentIndex = goal.priority.rawValue

    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveDetailSegue" {
            goal.name = nameField.text!
            goal.details = detailsField.text!
            goal.priority = PriorityType(rawValue: priorityControl.selectedSegmentIndex)!
            goal.endTime = selectedDate

            delegate.didSave(goal, indexPath: selectedIndexpath)

        } else if segue.identifier == "showDatePicker" {
            let datePickerController = segue.destinationViewController as! DatePickerViewController
            datePickerController.delegate = self
            datePickerController.date = goal.endTime

            datePickerController.modalPresentationStyle = .FormSheet
            datePickerController.modalTransitionStyle = .CrossDissolve
        }
    }

    func selectDate(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("showDatePicker", sender: self)
    }

    @IBAction func cancelDate(segue: UIStoryboardSegue) {}
    @IBAction func saveDate(segue: UIStoryboardSegue) {}

    /// Uses medium style date
    private func getDateString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.locale = NSLocale.currentLocale()
        return dateFormatter.stringFromDate(date)
    }
}

extension GoalDetailViewController: DatePickerDelegate {
    func didSave(date: NSDate) {
        selectedDate = date
        deadlineField.textLabel?.text = getDateString(date)
    }
}