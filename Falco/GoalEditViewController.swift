//
//  GoalDetailViewController.swift
//  Falco
//
//  Created by Gerald on 22/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GoalEditViewController: UITableViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var detailsField: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var usersCell: UsersCell!
    @IBOutlet weak var usersCellTable: UITableView!

    private var isNewGoal = false
    private let nameRow = 0
    private let dateRow = 1
    private let assignedUsersLabelRow = 4
    private let descriptionRow = 6
    private let datePickerRowHeight: CGFloat = 100
    private let assignedUsersTableRowHeight: CGFloat = 100
    private var isDatePickerShown = false
    private var isAssignedUsersTableShown = false
    private var isGroup: Bool {
        return group != nil
    }
    private var isPriorityModified = false

    var delegate: Savable!
    var goal: Goal!
    var group: Group?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Loading of goal information

        if goal == nil {
            if let group = group {
                var gGoal = GroupGoal(groupId: group.id, name: "", details: "", endTime: NSDate())
                for user in group.members { // by default, every member is assigned
                    gGoal.addUser(user)
                }
                goal = gGoal
            } else {
                goal = PersonalGoal(name: "", details: "", endTime: NSDate())
            }
            navigationItem.title = "New Goal"
            isNewGoal = true
        }

        nameField.text = goal.name
        dateLabel.text = getDateString(goal.endTime)
        datePicker.setDate(goal.endTime, animated: false)
        if goal.priority < 1 {
            priorityControl.selectedSegmentIndex = 0
        } else if goal.priority < 2 {
            priorityControl.selectedSegmentIndex = 1
        } else {
            priorityControl.selectedSegmentIndex = 2
        }
        detailsField.text = goal.details
        
        if isGroup {
            usersCellTable.layer.borderWidth = 1
            usersCellTable.layer.cornerRadius = 5
            usersCellTable.layer.borderColor = UIColor(red: 0, green: 118/255, blue: 1, alpha: 1).CGColor

            usersCell.initUsers(goal as! GroupGoal, groupMembers: group!.members, isNewGoal: isNewGoal)
        }

        // UI preparation

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45

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
        if isPriorityModified {
            goal.priority = Double(priorityControl.selectedSegmentIndex)
        }
        goal.endTime = datePicker.date

        if isGroup {
            var gGoal = goal as! GroupGoal
            for member in group!.members {
                if usersCell.isUserAssigned[member]! {
                    if !gGoal.isUserAssigned(member) {
                        gGoal.addUser(member)
                    }
                } else {
                    if gGoal.isUserAssigned(member) {
                        gGoal.removeUser(member)
                    }
                }
            }
            goal = gGoal
        }

        delegate.didSaveGoal(goal)
        dismissViewControllerAnimated(true, completion: nil)
    }

    //  Listening for primary action, in this case .ValueChanged. Therefore tapping on
    //  already selected segment does not hide date picker
    @IBAction func priorityTapped(sender: UISegmentedControl) {
        isPriorityModified = true
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
        
        if isGroup && indexPath.row == assignedUsersLabelRow && !isAssignedUsersTableShown {
            showAssignedUsersTable()
        } else {
            hideAssignedUsersTable()
        }

        if indexPath.row == nameRow {
            nameField.becomeFirstResponder()
        } else if indexPath.row == descriptionRow {
            detailsField.becomeFirstResponder()
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == dateRow + 1 {
            if isDatePickerShown {
                return datePickerRowHeight
            } else {
                return 0
            }
        } else if indexPath.row == assignedUsersLabelRow {
            if isGroup {
                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            } else {
                return 0
            }
        } else if indexPath.row == assignedUsersLabelRow + 1 {
            if isGroup && isAssignedUsersTableShown {
                return usersCellTable.contentSize.height
            } else {
                return 0
            }
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
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
        tableView.beginUpdates()
        tableView.endUpdates()

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
        tableView.beginUpdates()
        tableView.endUpdates()

        UIView.animateWithDuration(0.2, animations: {
            self.datePicker.alpha = 0
        }, completion: { finished in
            self.datePicker.hidden = true
            self.updatePopupSize()
        })
    }
    
    private func showAssignedUsersTable() {
        guard !isAssignedUsersTableShown else {
            return
        }
        isAssignedUsersTableShown = true
        
        // idiom to animate row height changes
        tableView.beginUpdates()
        tableView.endUpdates()
        
        usersCellTable.hidden = false
        UIView.animateWithDuration(0.2, animations: {
            self.usersCellTable.alpha = 1
            }, completion: { finished in
                self.updatePopupSize()
        })
    }
    
    private func hideAssignedUsersTable() {
        guard isAssignedUsersTableShown else {
            return
        }
        isAssignedUsersTableShown = false
        
        // idiom to animate row height changes
        tableView.beginUpdates()
        tableView.endUpdates()
        
        UIView.animateWithDuration(0.2, animations: {
            self.usersCellTable.alpha = 0
            }, completion: { finished in
                self.usersCellTable.hidden = true
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
        hideAssignedUsersTable()
        return true
    }
}

extension GoalEditViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        hideDatePicker()
        hideAssignedUsersTable()
        return true
    }
}
