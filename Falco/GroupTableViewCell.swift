//
//  GroupTableViewCell.swift
//  Falco
//
//  Created by Jing Yin Ong on 7/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation
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
        var offsetX = CGFloat(self.frame.size.width/2)
        let width = self.frame.height - 2
        for name in previewGoalNames {            
            let previewGoal = BubbleCell(frame: CGRectMake(offsetX, 0, width, width))
            previewGoal.label.text = name
            offsetX += width
            self.addSubview(previewGoal)
            self.bringSubviewToFront(previewGoal)
        }
    }
}
