//
//  BubbleCell.swift
//  Falco
//
//  Created by Gerald on 16/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class BubbleCell: UIView {
    private var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = frame.size.width/2
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = Constants.bubbleBorderWidth
        
        let backgroundImage = UIImageView(image: UIImage(named: "bubble"))
        backgroundImage.contentMode = .ScaleToFill
        backgroundImage.frame.size = frame.size
        addSubview(backgroundImage)
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width))
        label.center = CGPoint(x: frame.size.width/2, y: frame.size.width/2)
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(Constants.bubbleCellLabelFontSize)
        label.textColor = UIColor.whiteColor()
        addSubview(label)
    }

    convenience init(frame: CGRect, goal: Goal) {
        self.init(frame: frame)
        label.text = goal.name
        updateStrokeColour(goal.endTime)
        if let goal = goal as? GroupGoal {
            let center = CGPoint(x: frame.size.width/2, y: frame.size.width/2)
            let radius = frame.size.width / 2 * Constants.bubbleScaleFactor
            let (cPath, iPath) = BubbleCell.makeDashedCircle(center, radius: radius, involved: goal.usersAssignedCount, completed: goal.usersCompletedCount)
            let cRing = CAShapeLayer()
            cRing.path = cPath
            cRing.fillColor = nil
            cRing.strokeColor = UIColor.greenColor().CGColor
            cRing.lineWidth = Constants.bubbleBorderWidth
            let iRing = CAShapeLayer()
            iRing.path = iPath
            iRing.fillColor = nil
            iRing.strokeColor = UIColor.grayColor().CGColor
            iRing.lineWidth = Constants.bubbleBorderWidth
            let ring = UIView(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
            ring.layer.addSublayer(cRing)
            ring.layer.addSublayer(iRing)
            ring.center = CGPoint(x: frame.size.width/2 * Constants.bubbleScaleFactor,
                                  y: frame.size.width/2 * Constants.bubbleScaleFactor)
            addSubview(ring)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// days are rounded down
    private func daysToDeadline(deadline: NSDate) -> Int {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()

        let days = calendar.components(.Day, fromDate: now, toDate: deadline,
                                       options: .MatchNextTimePreservingSmallerUnits).day

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

    private static func makeDashedCircle(origin: CGPoint, radius: CGFloat, involved: Int, completed: Int) -> (CGPath, CGPath) {
        let startAngle = CGFloat(-M_PI_2)
        let endAngle = startAngle - CGFloat(M_PI * 2)
        let completionRatio: CGFloat = CGFloat(completed) / CGFloat(involved)
        let completionRatioToAngle = startAngle - CGFloat(M_PI * 2) * completionRatio
        let circumference = 2 * CGFloat(M_PI) * radius

        let arcForCompleted =
            UIBezierPath(arcCenter: origin, radius: radius, startAngle: startAngle, endAngle: completionRatioToAngle, clockwise: false)
        let arcForIncompleted = UIBezierPath(arcCenter: origin, radius: radius, startAngle: completionRatioToAngle, endAngle: endAngle, clockwise: false)

        let pattern = getPattern(circumference, segments: involved)

        let dashedPathForCompleted = CGPathCreateCopyByDashingPath(arcForCompleted.CGPath, nil, 0, pattern, pattern.count)
        let dashedPathForIncompleted = CGPathCreateCopyByDashingPath(arcForIncompleted.CGPath, nil, 0, pattern, pattern.count)

        return (dashedPathForCompleted!, dashedPathForIncompleted!)
    }

    private static func getPattern(points: CGFloat, segments: Int) -> [CGFloat] {
        let pointsPerSegment = points / CGFloat(segments)
        let drawnLength = Constants.drawnToGapRatio * pointsPerSegment
        let gapLength = (1 - Constants.drawnToGapRatio) * pointsPerSegment

        return [drawnLength, gapLength]
    }
}
