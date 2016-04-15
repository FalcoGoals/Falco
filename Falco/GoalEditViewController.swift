//
//  GoalDetailViewController.swift
//  Falco
//
//  Created by Gerald on 22/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

protocol GoalEditDelegate {
    var goal: Goal { get set }
    var members: [User] { get set }
}

class GoalEditViewController: UITableViewController {
    private var isGroup: Bool { return group != nil }

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var detailsField: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!

    let nameRow = 0
    let dateRow = 1
    let descriptionRow = 4
    let datePickerRowHeight: CGFloat = 100

    var delegate: GoalEditDelegate!

    var goal: Goal!
    var group: Group?
    var isDatePickerShown = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Loading of goal information

        if goal == nil {
            if isGroup {
                var gGoal = GroupGoal(groupId: group!.id, name: "", details: "", endTime: NSDate())
                for user in group!.members { // by default, every member is assigned
                    gGoal.addUser(user)
                }
                goal = gGoal
            } else {
                goal = PersonalGoal(name: "", details: "", endTime: NSDate())
            }
            navigationItem.title = "New Goal"
        }

        nameField.text = goal.name
        dateLabel.text = getDateString(goal.endTime)
        datePicker.setDate(goal.endTime, animated: false)
        priorityControl.selectedSegmentIndex = goal.priority
        detailsField.text = goal.details

        // UI preparation

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 45

        detailsField.layer.borderWidth = 1
        detailsField.layer.cornerRadius = 5
        detailsField.layer.borderColor = UIColor(red: 0, green: 118/255, blue: 1, alpha: 1).CGColor
        detailsField.scrollEnabled = false

        tableView.backgroundColor = UIColor.clearColor()
        let blurEffect = UIBlurEffect(style: .ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        tableView.backgroundView = blurEffectView
        if let popover = navigationController?.popoverPresentationController {
            popover.backgroundColor = UIColor.clearColor()
            updatePopupSize()
        }
    }

    override func viewDidAppear(animated: Bool) {
        detailsField.scrollEnabled = true
        nameField.becomeFirstResponder()
        updatePopupSize()
    }

    // MARK: IB Actions

    @IBAction func saveDetails(sender: UIBarButtonItem) {
        goal.name = nameField.text!
        goal.details = detailsField.text!
        goal.priority = priorityControl.selectedSegmentIndex
        goal.endTime = datePicker.date

        delegate.didSave(goal)
        dismissViewControllerAnimated(true, completion: nil)
    }

    /// Listening for primary action, in this case .ValueChanged. Therefore tapping on already selected segment does not hide date picker
    @IBAction func priorityTap(sender: UISegmentedControl) {
        hideDatePicker()
    }

    @IBAction func dateChanged(sender: UIDatePicker) {
        dateLabel.text = getDateString(sender.date)
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // hide any opened keyboard
        self.tableView.endEditing(true)

        if indexPath.row == dateRow && !isDatePickerShown {
            showDatePicker()
        } else {
            hideDatePicker()
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

    // MARK: Helper methods

    /// Uses medium style date
    private func getDateString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.locale = NSLocale.currentLocale()
        return dateFormatter.stringFromDate(date)
    }

    private func showDatePicker() {
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
            self.updatePopupSize()
        })

    }

    private func hideDatePicker() {
        guard isDatePickerShown else {
            return
        }
        isDatePickerShown = false

        // idiom to animate row height changes
        self.tableView.beginUpdates()
        self.tableView.endUpdates()

        UIView.animateWithDuration(0.2, animations: {
            self.datePicker.alpha = 0
        }, completion: { finished in
            self.datePicker.hidden = true
            self.updatePopupSize()
        })
    }

    private func updatePopupSize() {
        tableView.layoutIfNeeded()
        preferredContentSize = tableView.sizeThatFits(CGSizeMake(preferredContentSize.width, CGFloat.max))
        presentingViewController?.presentedViewController?.preferredContentSize = preferredContentSize
    }
}

extension GoalEditViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        hideDatePicker()
        return true
    }
}

extension GoalEditViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        hideDatePicker()
        return true
    }
}
