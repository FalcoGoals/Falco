//
//  GroupTableViewCell.swift
//  Falco
//
//  Created by Jing Yin Ong on 7/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    private let numGoalPreview = 3

    @IBOutlet weak var groupNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setPreviewGoals(goals: GoalCollection) {
        let spacing: CGFloat = 20
        let goalWidth = frame.height - groupNameLabel.frame.height - 2 * spacing
        let goalsTotalWidth = CGFloat(goals.count) * (goalWidth + spacing) - spacing
        var offsetX: CGFloat = (frame.width - goalsTotalWidth) / 2
        let offsetY = groupNameLabel.frame.height + spacing

        goals.sortGoalsByWeight()
        var topGoals = [Goal]()
        for i in 0..<min(numGoalPreview, goals.count) {
            topGoals.append(goals.goals[i])
        }
        for goal in topGoals {
            let previewGoal = BubbleCell(frame: CGRectMake(offsetX, offsetY, goalWidth, goalWidth), goal: goal)
            offsetX += goalWidth + spacing
            self.addSubview(previewGoal)
            self.bringSubviewToFront(previewGoal)
        }
    }
}
