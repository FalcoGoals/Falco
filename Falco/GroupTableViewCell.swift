//
//  GroupTableViewCell.swift
//  Falco
//
//  Created by Jing Yin Ong on 7/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupSettingsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setPreviewGoals(goals: GoalCollection) {
        for subview in subviews where subview is BubbleCell {
            subview.removeFromSuperview()
        }

        guard !goals.isEmpty else {
            return
        }

        let maxGoalWidth = frame.height - groupNameLabel.frame.height - 2 * Constants.goalPreviewSpacing

        goals.sortGoalsByWeight()
        var goalWidths = [CGFloat]()
        var goalsTotalWidth: CGFloat = 0

        let topGoal = goals.goals[0]
        var topGoals = [Goal]()
        for i in 0..<min(Constants.numGoalPreview, goals.count) {
            let goal = goals.goals[i]
            let normalisedWeight = CGFloat(goal.weight) / CGFloat(topGoal.weight)
            let calculatedWidth = maxGoalWidth * normalisedWeight
            goalsTotalWidth += calculatedWidth + Constants.goalPreviewSpacing
            goalWidths.append(calculatedWidth)
            topGoals.append(goal)
        }
        goalsTotalWidth -= Constants.goalPreviewSpacing

        var offsetX: CGFloat = (frame.width - goalsTotalWidth) / 2
        let offsetY = groupNameLabel.frame.height + Constants.goalPreviewSpacing
        for i in 0..<topGoals.count {
            let goal = topGoals[i]
            let width = goalWidths[i]
            let bubble = BubbleCell(frame: CGRect(x: offsetX, y: offsetY, width: width, height: width), goal: goal)
            offsetX += width + Constants.goalPreviewSpacing
            addSubview(bubble)
            bringSubviewToFront(bubble)
        }
    }
}
