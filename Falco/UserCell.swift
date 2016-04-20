//
//  AssignedUserTableViewCell.swift
//  Falco
//
//  Created by Lim Kiat on 16/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    private var _user: User!
    private var _isNewGoal: Bool!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var user: User { return _user }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func initUser(user: User, completionTime: NSDate? = nil) {
        _user = user
        nameLabel.text = user.name
        if let completionTime = completionTime {
            _isNewGoal = false
            updateCompletionStatus(completionTime)
        } else {
            _isNewGoal = true
            dateLabel.text = ""
        }
    }

    func updateCompletionStatus(completionTime: NSDate) {
        guard !_isNewGoal! else {
            return
        }

        if accessoryType == .None {
            dateLabel.text = ""
        } else if completionTime != Constants.incompleteTimeValue {
            dateLabel.text = getDateString(completionTime)
        } else {
            dateLabel.text = Constants.uncompletedDateLabel
        }
    }

    /// Uses medium style date
    private func getDateString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.locale = NSLocale.currentLocale()
        return dateFormatter.stringFromDate(date)
    }
}