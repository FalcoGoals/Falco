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

class GoalDetailViewController: UITableViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var detailsField: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priorityControl: UISegmentedControl!

    let dateRow = 2

    var delegate: GoalDetailDelegate!

    var goal: Goal!
    var selectedDate: NSDate!
    var selectedIndexpath: NSIndexPath?

    var datePickerIndexPath: NSIndexPath!
    let datePickerIdentifier = "datePickerCell"
    var isDatePickerShown: Bool {
        return datePickerIndexPath != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if goal == nil {
            goal = PersonalGoal(name: "New Goal", details: "", priority: .Mid, endTime: NSDate())
        }

        nameField.text = goal.name
        detailsField.text = goal.details
        dateLabel.text = getDateString(goal.endTime)
        selectedDate = goal.endTime
        priorityControl.selectedSegmentIndex = goal.priority.rawValue

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
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.row == dateRow {
//            showDatePicker(indexPath)
//        } else {
//            hideDatePicker(indexPath)
//        }
//    }

//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//
//    }
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell: UITableViewCell
//        if isDatePickerShown && indexPath == datePickerIndexPath {
//            cell = createDatePickerCell(indexPath)
//        } else {
//            cell = self.tableView.cellForRowAtIndexPath(indexPath)!
//        }
//        return cell
//    }

    @IBAction func saveDetails(sender: UIButton) {
        goal.name = nameField.text!
        goal.details = detailsField.text!
        goal.priority = PriorityType(rawValue: priorityControl.selectedSegmentIndex)!
        goal.endTime = selectedDate

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

        datePickerIndexPath = NSIndexPath(forRow: dateRow + 1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([datePickerIndexPath], withRowAnimation: .Fade)
    }

    private func hideDatePicker(indexPath: NSIndexPath) {
        guard isDatePickerShown else {
            return
        }
        self.tableView.deleteRowsAtIndexPaths([datePickerIndexPath], withRowAnimation: .Fade)
        datePickerIndexPath = nil
    }

    //    private func createDatePickerCell(indexPath: NSIndexPath) -> UITableViewCell {
    //        let datePicker = UITableViewCell(style: .Default, reuseIdentifier: datePickerIdentifier) as! UIDatePicker
    //        datePicker.setDate(goal!.endTime, animated: true)
    //        return datePicker
    //    }
}