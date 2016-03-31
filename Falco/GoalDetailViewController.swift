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
    @IBOutlet weak var detailsField: UITextField!
    @IBOutlet weak var deadlineField: UITableViewCell!
    @IBOutlet weak var priorityControl: UISegmentedControl!

    var user: User!
    var goal: Goal?
    var selectedIndexpath: NSIndexPath?
    var delegate: GoalDetailDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        if goal == nil {
            goal = PersonalGoal(user: user, id: NSUUID().UUIDString, name: "New Goal", details: "", endTime: NSDate(), priority: .Mid)
        }

        title = goal!.name
        detailsField.text = goal!.details
        deadlineField.textLabel?.text = getDateString(goal!.endTime)
        priorityControl.selectedSegmentIndex = goal!.priority.rawValue

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveDetailSegue" {
            goal!.details = detailsField.text!
            goal!.priority = PriorityType(rawValue: priorityControl.selectedSegmentIndex)!

            delegate.didSave(goal!, indexPath: selectedIndexpath)

        } else if segue.identifier == "showDatePicker" {
            let datePickerController = segue.destinationViewController as! DatePickerViewController
            datePickerController.delegate = self
            datePickerController.date = goal!.endTime

            datePickerController.modalPresentationStyle = .FormSheet
            datePickerController.modalTransitionStyle = .CrossDissolve
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section == 1 && indexPath.row == 0 else {
            return
        }

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
        goal!.endTime = date
        deadlineField.textLabel?.text = getDateString(date)
    }
}