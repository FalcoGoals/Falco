//
//  GoalDetailViewController.swift
//  Falco
//
//  Created by Gerald on 22/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

protocol GoalDetailDelegate {
    func didSave(goal: Goal)
}

class GoalEditViewController: UITableViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var detailsField: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!

    let nameRow = 0
    let descriptionRow = 1
    let dateRow = 2
    let datePickerRowHeight: CGFloat = 100

    var delegate: GoalDetailDelegate!

    var goal: Goal!
    var selectedDate: NSDate!
    var isDatePickerShown = false
    var dateHolder: NSDate!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 45

        if goal == nil {
            goal = PersonalGoal(name: "New Goal", details: "", priority: .Mid, endTime: NSDate())
        }

        nameField.text = goal.name
        detailsField.text = goal.details
        dateLabel.text = getDateString(goal.endTime)
        priorityControl.selectedSegmentIndex = goal.priority.rawValue

        dateHolder = goal.endTime

        detailsField.layer.borderWidth = 1
        detailsField.layer.cornerRadius = 5
        detailsField.layer.borderColor = UIColor(red: 0, green: 118/255, blue: 1, alpha: 1).CGColor
        detailsField.scrollEnabled = false

        tableView.backgroundColor = UIColor.clearColor()
        let blurEffect = UIBlurEffect(style: .ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        tableView.backgroundView = blurEffectView
        if let popover = popoverPresentationController {
            popover.backgroundColor = UIColor.clearColor()
        }
    }

    override func viewDidAppear(animated: Bool) {
        detailsField.scrollEnabled = true
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }

    // MARK: Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == dateRow {
            showDatePicker(indexPath)
        } else {
            hideDatePicker(indexPath)
        }

        if indexPath.row == nameRow {
            nameField.becomeFirstResponder()
        } else if indexPath.row == descriptionRow {
            detailsField.becomeFirstResponder()
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard indexPath.section == 0 && indexPath.row == dateRow + 1 else {
            return self.tableView.rowHeight
        }

        if !isDatePickerShown {
            return 0
        } else {
            return datePickerRowHeight
        }
    }

    @IBAction func saveDetails(sender: UIButton) {
        goal.name = nameField.text!
        goal.details = detailsField.text!
        goal.priority = PriorityType(rawValue: priorityControl.selectedSegmentIndex)!
        goal.endTime = datePicker.date

        delegate.didSave(goal)
    }

    /// Uses medium style date
    private func getDateString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.locale = NSLocale.currentLocale()
        return dateFormatter.stringFromDate(date)
    }
    private func showDatePicker(indexPath: NSIndexPath) {
        guard !isDatePickerShown else {
            return
        }
        isDatePickerShown = true

        // idiom to animate row height changes
        self.tableView.beginUpdates()
        self.tableView.endUpdates()

        datePicker.hidden = false
        UIView.animateWithDuration(0.2, animations: {
            self.datePicker.alpha = 1
        }, completion: { finished in
            self.datePicker.setDate(self.dateHolder, animated: true)
        })

    }

    private func hideDatePicker(indexPath: NSIndexPath) {
        guard isDatePickerShown else {
            return
        }
        isDatePickerShown = false

        // idiom to animate row height changes
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        self.dateHolder = self.datePicker.date

        UIView.animateWithDuration(0.2, animations: {
            self.datePicker.alpha = 0
        }, completion: { finished in
            self.datePicker.hidden = true
            self.dateLabel.text = self.getDateString(self.dateHolder)
        })
    }
}