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
        
        layer.cornerRadius = self.frame.size.width/2
//        clipsToBounds = true
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
        if let goal = goal as? GroupGoal {
            let center = CGPointMake(frame.size.width/2, frame.size.width/2)
            let radius = frame.size.width / 2 * 1.05
            let (cPath, iPath) = BubbleCell.makeDashedCircle(center, radius: radius, involved: goal.usersAssignedCount, completed: goal.usersCompletedCount)
            let cRing = CAShapeLayer()
            cRing.path = cPath
            cRing.fillColor = nil
            cRing.strokeColor = UIColor.greenColor().CGColor
            cRing.lineWidth = 2
            let iRing = CAShapeLayer()
            iRing.path = iPath
            iRing.fillColor = nil
            iRing.strokeColor = UIColor.grayColor().CGColor
            iRing.lineWidth = 2
            let ring = UIView(frame: CGRectMake(0, 0, radius * 2, radius * 2))
            ring.layer.addSublayer(cRing)
            ring.layer.addSublayer(iRing)
            ring.center = CGPointMake(frame.size.width/2 * 1.05, frame.size.width/2 * 1.05)
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

//        let dashedCircleForCompleted = SKShapeNode(path: dashedPathForCompleted!)
//        dashedCircleForCompleted.strokeColor = UIColor.greenColor()
//        dashedCircleForCompleted.lineWidth = lineWidth
//
//        let dashedCircleForIncompeleted = SKShapeNode(path: dashedPathForIncompleted!)
//        dashedCircleForIncompeleted.strokeColor = UIColor.grayColor()
//        dashedCircleForIncompeleted.lineWidth = lineWidth
//
//        let parentNode = SKShapeNode()
//        parentNode.addChild(dashedCircleForCompleted)
//        parentNode.addChild(dashedCircleForIncompeleted)
//        return parentNode
    }

    private static func getPattern(points: CGFloat, segments: Int) -> [CGFloat] {
        let drawnToGapRatio: CGFloat = 9 / 10
        let pointsPerSegment = points / CGFloat(segments)
        let drawnLength = drawnToGapRatio * pointsPerSegment
        let gapLength = (1 - drawnToGapRatio) * pointsPerSegment

        return [drawnLength, gapLength]
    }
}
