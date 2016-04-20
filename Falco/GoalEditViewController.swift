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
            navigationItem.title = Constants.newGoalTitle
            isNewGoal = true
        }

        nameField.text = goal.name
        dateLabel.text = getDateString(goal.endTime)
        datePicker.setDate(goal.endTime, animated: false)
        if goal.priority < Double(Constants.mediumPriorityIndex) {
            priorityControl.selectedSegmentIndex = Constants.lowPriorityIndex
        } else if goal.priority < Double(Constants.highPriorityIndex) {
            priorityControl.selectedSegmentIndex = Constants.mediumPriorityIndex
        } else {
            priorityControl.selectedSegmentIndex = Constants.highPriorityIndex
        }
        detailsField.text = goal.details
        
        if isGroup {
            usersCellTable.layer.borderWidth = Constants.usersCellTableBorderWidth
            usersCellTable.layer.cornerRadius = Constants.usersCellTableCornerRadius
            usersCellTable.layer.borderColor = Constants.usersCellTableBorderColor

            usersCell.initUsers(goal as! GroupGoal, groupMembers: group!.members, isNewGoal: isNewGoal)
        }

        // UI preparation

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight

        detailsField.layer.borderWidth = Constants.detailsFieldBorderWidth
        detailsField.layer.cornerRadius = Constants.detailsFieldCornerRadius
        detailsField.layer.borderColor = Constants.detailsFieldBorderColor
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

        if indexPath.row == Constants.dateRow && !isDatePickerShown {
            showDatePicker()
        } else {
            hideDatePicker()
        }
        
        if isGroup && indexPath.row == Constants.assignedUsersLabelRow && !isAssignedUsersTableShown {
            showAssignedUsersTable()
        } else {
            hideAssignedUsersTable()
        }

        if indexPath.row == Constants.nameRow {
            nameField.becomeFirstResponder()
        } else if indexPath.row == Constants.descriptionRow {
            detailsField.becomeFirstResponder()
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == Constants.dateRow + 1 {
            if isDatePickerShown {
                return Constants.datePickerRowHeight
            } else {
                return 0
            }
        } else if indexPath.row == Constants.assignedUsersLabelRow {
            if isGroup {
                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            } else {
                return 0
            }
        } else if indexPath.row == Constants.assignedUsersLabelRow + 1 {
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
        preferredContentSize = tableView.sizeThatFits(CGSize(width: preferredContentSize.width, height: CGFloat.max))
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
