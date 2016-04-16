//
//  GoalBubble.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import SpriteKit

class GoalBubble: SKNode {
    var id: String
    var circle: SKShapeNode
    var ring: SKShapeNode?
    var label: SKLabelNode

    private var radius: CGFloat {
        didSet {
            let scaleFactor = radius / oldValue
            let scale = SKAction.scaleBy(scaleFactor, duration: 0.5)
            circle.runAction(scale, completion: {
                self.label.physicsBody = self.makeCircularBody(self.radius)
            })
            if let ring = self.ring {
                ring.runAction(scale)
            }
        }
    }

    /// Calculate full circumference in points
    private var circumference: CGFloat {
        let PI = CGFloat(M_PI)
        let circumference = 2 * PI * self.radius
        return circumference
    }

    private var goalName: String {
        didSet {
            label.text = goalName
        }
    }
    private var deadline: NSDate {
        didSet {
            updateStrokeColour(deadline)
        }
    }
    private var bubbleTexture = SKTexture(imageNamed: "bubble")

    private class var circleToRingRatio: CGFloat {
        return 0.95
    }

    init(id: String, circleOfRadius: CGFloat, text: String, deadline: NSDate) {
        self.id = id
        self.radius = circleOfRadius
        self.goalName = text
        self.deadline = deadline

        self.circle = SKShapeNode(circleOfRadius: circleOfRadius * GoalBubble.circleToRingRatio)
        self.label = SKLabelNode(text: text)
        while label.frame.width >= radius * 2 {
            label.text = String(label.text!.characters.dropLast())
        }

        super.init()

        self.userInteractionEnabled = true
        self.name = id

        self.ring = makeDashedCircle(self.circle.position, radius: circleOfRadius, completed: 1, involved: 10)
        self.ring!.strokeColor = UIColor.cyanColor()
        self.ring!.lineWidth = 2

        setCircleProperties(bubbleTexture)
        updateStrokeColour(deadline)

        self.label.physicsBody = makeCircularBody(circleOfRadius)

        setLabelProperties()

        addChild(self.label)

        self.label.addChild(self.circle)
        self.label.addChild(self.ring!)
    }

    convenience init(goal: Goal) {
        self.init(id: goal.id, circleOfRadius: CGFloat(goal.weight) / 2, text: goal.name, deadline: goal.endTime)
    }

    func updateWithGoal(goal: Goal) {
        label.text = goal.name
        if CGFloat(goal.weight)/2 != radius {
            radius = CGFloat(goal.weight)/2
        }
        deadline = goal.endTime
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Drawing related methods
    private func makeCircularBody(radius: CGFloat) -> SKPhysicsBody {
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.allowsRotation = false
        body.restitution = 0.2
        body.friction = 0.0
        body.linearDamping = 0.1
        return body
    }

    /**
     As UIKit and SpriteKit coordinate system is opposite, some calculations and parameters passed in here may
     not make sense initially
     
     - note: 
     clockwise: false is equivalent to clockwise
     
     angle A - angle B goes clockwise

     */
    private func makeDashedCircle(origin: CGPoint, radius: CGFloat, completed: Int, involved: Int) -> SKShapeNode {
        let startAngle = CGFloat(M_PI_2)
        let endAngle = startAngle - CGFloat(M_PI * 2)
        let completionRatio: CGFloat = CGFloat(completed) / CGFloat(involved)
        let completionRatioToAngle = startAngle - CGFloat(M_PI * 2) * completionRatio
        let lineWidth: CGFloat = 2

        let arcForCompleted =
            UIBezierPath(arcCenter: origin, radius: radius, startAngle: startAngle, endAngle: completionRatioToAngle, clockwise: false)
        let arcForIncompleted = UIBezierPath(arcCenter: origin, radius: radius, startAngle: completionRatioToAngle, endAngle: endAngle, clockwise: false)

        let pattern = getPattern(self.circumference, segments: involved)

        let dashedPathForCompleted = CGPathCreateCopyByDashingPath(arcForCompleted.CGPath, nil, 0, pattern, pattern.count)
        let dashedPathForIncompleted = CGPathCreateCopyByDashingPath(arcForIncompleted.CGPath, nil, 0, pattern, pattern.count)

        let dashedCircleForCompleted = SKShapeNode(path: dashedPathForCompleted!)
        dashedCircleForCompleted.strokeColor = UIColor.greenColor()
        dashedCircleForCompleted.lineWidth = lineWidth

        let dashedCircleForIncompeleted = SKShapeNode(path: dashedPathForIncompleted!)
        dashedCircleForIncompeleted.strokeColor = UIColor.cyanColor()
        dashedCircleForIncompeleted.lineWidth = lineWidth

        let parentNode = SKShapeNode()
        parentNode.addChild(dashedCircleForCompleted)
        parentNode.addChild(dashedCircleForIncompeleted)
        return parentNode
    }

    private func getPattern(points: CGFloat, segments: Int) -> [CGFloat] {
        let drawnToGapRatio: CGFloat = 9 / 10
        let pointsPerSegment = points / CGFloat(segments)
        let drawnLength = drawnToGapRatio * pointsPerSegment
        let gapLength = (1 - drawnToGapRatio) * pointsPerSegment

        return [drawnLength, gapLength]
    }

    private func updateStrokeColour(deadline: NSDate) {
        if let aShadeOfRed = UIColor.redColor().desaturate(times: daysToDeadline(deadline)) {
            self.circle.strokeColor = aShadeOfRed
        } else {
            self.circle.strokeColor = UIColor.whiteColor()
        }
    }


    // MARK: Helpers
    private func setCircleProperties(texture: SKTexture) {
        circle.fillColor = UIColor.whiteColor()
        circle.fillTexture = texture
        circle.lineWidth = 2
    }

    private func setLabelProperties() {
        self.label.horizontalAlignmentMode = .Center
        self.label.verticalAlignmentMode = .Baseline
        self.label.fontSize = 25
        self.label.fontName = "System-Bold"
        self.label.name = "label"
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
}

// MARK: 
extension UIColor {
    func changeSaturation(multiplier: Double, times: Int = 1) -> UIColor? {
        guard times > 0 else {
            return self
        }

        var h, s, b, a: CGFloat
        h = 0.0
        s = 0.0
        b = 0.0
        a = 0.0

        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            let factor = CGFloat(pow(multiplier, Double(times)))
            let color = UIColor(hue: h,
                                saturation: min(s * factor, 1.0),
                                brightness: b,
                                alpha: a)
            return color
        }
        return nil
    }

    /**
     - parameters:
        - times: number of times to call this method
    */
    func saturate(times times: Int = 1) -> UIColor? {
        let multiplier = 1.1
        return changeSaturation(multiplier, times: times)
    }

    /**
     - todo: configurable setting to change multiplier such that the number of times to reach saturation is 0
     can be tweaked by users. use case: 10 days might be long for some goals but too short for a big goal
     - parameters:
        - times: number of times to call this method 
     10 times gives close to a value of 0
     */
    func desaturate(times times: Int = 1) -> UIColor? {
        let multiplier = 0.8
        return changeSaturation(multiplier, times: times)
    }
}