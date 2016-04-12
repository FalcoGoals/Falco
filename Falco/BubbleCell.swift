//
//  BubbleCell.swift
//  Falco
//
//  Created by Gerald on 16/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class BubbleCell: UIView {
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = self.frame.size.width/2
        clipsToBounds = true
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 2.0
        let backgroundImage = UIImageView(image: UIImage(named: "bubble"))
        backgroundImage.contentMode = .ScaleToFill
        backgroundImage.frame.size = frame.size
        addSubview(backgroundImage)
        label = UILabel(frame: CGRectMake(0, 0, frame.size.width, frame.size.width))
        label.center = CGPointMake(frame.size.width/2, frame.size.width/2)
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(20)
        label.textColor = UIColor.whiteColor()
        addSubview(label)
    }

    convenience init(frame: CGRect, goal: Goal) {
        self.init(frame: frame)
        label.text = goal.name
        updateStrokeColour(goal.endTime)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// days are rounded down
    private func daysToDeadline(deadline: NSDate) -> Int {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()

        let days = calendar.components(.Day, fromDate: now, toDate: deadline, options: .MatchNextTimePreservingSmallerUnits).day

        if days < 0 {
            return 0
        } else {
            return days
        }
    }

    private func updateStrokeColour(deadline: NSDate) {
        if let aShadeOfRed = UIColor.redColor().desaturate(times: daysToDeadline(deadline)) {
            layer.borderColor = aShadeOfRed.CGColor
        } else {
            layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
}
