//
//  GroupTableViewCell.swift
//  Falco
//
//  Created by Jing Yin Ong on 7/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    //@IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    //var previewGoalNames: [String]!
    /// top goals display
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setPreviewGoalNames(previewGoalNames: [String]) {
        let spacing: CGFloat = 20
        let goalWidth = frame.height - groupNameLabel.frame.height - 2 * spacing
        let goalsTotalWidth = CGFloat(previewGoalNames.count) * (goalWidth + spacing) - spacing
        var offsetX: CGFloat = (frame.width - goalsTotalWidth) / 2
        let offsetY = groupNameLabel.frame.height + spacing
        for name in previewGoalNames {
            let previewGoal = BubbleCell(frame: CGRectMake(offsetX, offsetY, goalWidth, goalWidth))
            previewGoal.label.text = name
            offsetX += goalWidth + spacing
            self.addSubview(previewGoal)
            self.bringSubviewToFront(previewGoal)
        }
    }
}
