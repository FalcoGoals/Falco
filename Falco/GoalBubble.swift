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
    var groupId: String?
    var circle: SKShapeNode
    var ring: SKShapeNode?
    var label: SKLabelNode

    private var involved: Int?
    private var completed: Int
    private var hasRing: Bool {
        return involved != nil
    }
    private var circleToRingRatio: CGFloat
    private var initialRadius: CGFloat!
    private var _radius: CGFloat
    private var initialScale: CGFloat

    private let minRadius: CGFloat = 50
    private let maxRadius: CGFloat = 300

    var radius: CGFloat {
        get {
            return _radius
        }
        set(newRadius) {
            let scaleFactor = newRadius / _radius
            let scale = SKAction.scaleBy(scaleFactor, duration: 0.5)
            circle.runAction(scale, completion: {
                self.label.physicsBody = GoalBubble.makeCircularBody(newRadius)
            })
            if let ring = self.ring {
                ring.runAction(scale)
            }
            _radius = newRadius
        }
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

    init(id: String, groupId: String? = nil, circleOfRadius: CGFloat, text: String, deadline: NSDate, involved: Int? = nil, completed: Int = 0) {
        self.id = id
        self.groupId = groupId
        self._radius = circleOfRadius
        self.goalName = text
        self.deadline = deadline

        self.involved = involved
        self.completed = completed

        if involved != nil {
            self.circleToRingRatio = 0.95
        } else {
            self.circleToRingRatio = 1
        }

        self.label = SKLabelNode(text: text)
        while label.frame.width >= _radius * 2 {
            label.text = String(label.text!.characters.dropLast())
        }

        self.circle = SKShapeNode(circleOfRadius: circleOfRadius * self.circleToRingRatio)
        self.initialScale = self.circle.xScale

        if involved != nil {
            self.ring =
                GoalBubble.makeDashedCircle(self.circle.position, radius: circleOfRadius, involved: involved!, completed: completed)
            self.label.addChild(self.ring!)
        }

        self.label.addChild(self.circle)

        super.init()

        self.userInteractionEnabled = true
        self.name = id

        setCircleProperties(bubbleTexture)
        updateStrokeColour(deadline)
        setLabelProperties()

        self.label.physicsBody = GoalBubble.makeCircularBody(circleOfRadius)

        addChild(self.label)
    }

    convenience init(goal: Goal) {
        if let goal = goal as? GroupGoal {
            self.init(id: goal.id, groupId: goal.groupId, circleOfRadius: CGFloat(goal.weight) / 2, text: goal.name, deadline: goal.endTime, involved: goal.usersAssignedCount, completed: goal.usersCompletedCount)
        } else {
            self.init(id: goal.id, circleOfRadius: CGFloat(goal.weight) / 2, text: goal.name, deadline: goal.endTime)
        }
    }

    func beginScaling(scale: CGFloat) {
        initialScale = circle.xScale
        scaleTo(scale)
    }

    func scaleTo(scale: CGFloat, commit: Bool = false, labelText: String = "") {
        let newRadius = scale * _radius
        var curatedScale = scale
        if newRadius > maxRadius {
            curatedScale = maxRadius / _radius
        } else if newRadius < minRadius {
            curatedScale = minRadius / _radius
        }
        let scaleAction = SKAction.scaleTo(curatedScale * initialScale, duration: 0)
        if commit {
            initialScale *= curatedScale
            _radius *= curatedScale
        }
        circle.runAction(scaleAction) {
            if commit {
                self.label.physicsBody = GoalBubble.makeCircularBody(self._radius)
                self.label.text = labelText
                while self.label.frame.width >= self._radius * 2 {
                    self.label.text = String(self.label.text!.characters.dropLast())
                }
            }
        }
        ring?.runAction(scaleAction)
    }

    func finishScaling(scale: CGFloat, goal: Goal) {
        scaleTo(scale, commit: true, labelText: goal.name)
    }

    func updateWithGoal(goal: Goal) {
        if CGFloat(goal.weight)/2 != radius {
            radius = CGFloat(goal.weight)/2
        }
        label.text = goal.name
        while label.frame.width >= radius * 2 {
            label.text = String(label.text!.characters.dropLast())
        }
        deadline = goal.endTime
        if let goal = goal as? GroupGoal {
            self.ring!.removeFromParent()
            self.ring =
                GoalBubble.makeDashedCircle(self.circle.position, radius: radius, involved: goal.usersAssignedCount, completed: goal.usersCompletedCount)
            self.label.addChild(self.ring!)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Drawing related methods
    private static func makeCircularBody(radius: CGFloat) -> SKPhysicsBody {
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
    private static func makeDashedCircle(origin: CGPoint, radius: CGFloat, involved: Int, completed: Int) -> SKShapeNode {
        let startAngle = CGFloat(M_PI_2)
        let endAngle = startAngle - CGFloat(M_PI * 2)
        let completionRatio: CGFloat = CGFloat(completed) / CGFloat(involved)
        let completionRatioToAngle = startAngle - CGFloat(M_PI * 2) * completionRatio
        let circumference = 2 * CGFloat(M_PI) * radius
        let lineWidth: CGFloat = 2

        let arcForCompleted =
            UIBezierPath(arcCenter: origin, radius: radius, startAngle: startAngle, endAngle: completionRatioToAngle, clockwise: false)
        let arcForIncompleted = UIBezierPath(arcCenter: origin, radius: radius, startAngle: completionRatioToAngle, endAngle: endAngle, clockwise: false)

        let pattern = getPattern(circumference, segments: involved)

        let dashedPathForCompleted = CGPathCreateCopyByDashingPath(arcForCompleted.CGPath, nil, 0, pattern, pattern.count)
        let dashedPathForIncompleted = CGPathCreateCopyByDashingPath(arcForIncompleted.CGPath, nil, 0, pattern, pattern.count)

        let dashedCircleForCompleted = SKShapeNode(path: dashedPathForCompleted!)
        dashedCircleForCompleted.strokeColor = UIColor.greenColor()
        dashedCircleForCompleted.lineWidth = lineWidth

        let dashedCircleForIncompeleted = SKShapeNode(path: dashedPathForIncompleted!)
        dashedCircleForIncompeleted.strokeColor = UIColor.grayColor()
        dashedCircleForIncompeleted.lineWidth = lineWidth

        let parentNode = SKShapeNode()
        parentNode.addChild(dashedCircleForCompleted)
        parentNode.addChild(dashedCircleForIncompeleted)
        return parentNode
    }

    private static func getPattern(points: CGFloat, segments: Int) -> [CGFloat] {
        let drawnToGapRatio: CGFloat = 9 / 10
        let pointsPerSegment = points / CGFloat(segments)
        let drawnLength = drawnToGapRatio * pointsPerSegment
        let gapLength = (1 - drawnToGapRatio) * pointsPerSegment

        return [drawnLength, gapLength]
    }

    private func updateStrokeColour(deadline: NSDate) {
        if let aShadeOfRed = UIColor.redColor().desaturate(times: GoalBubble.daysToDeadline(deadline)) {
            self.circle.strokeColor = aShadeOfRed
        } else {
            self.circle.strokeColor = UIColor.whiteColor()
        }
    }

    // MARK: Helpers
    private func setCircleProperties(texture: SKTexture) {
        self.circle.fillColor = UIColor.whiteColor()
        self.circle.fillTexture = texture
        self.circle.lineWidth = 2
    }

    private func setLabelProperties() {
        self.label.horizontalAlignmentMode = .Center
        self.label.verticalAlignmentMode = .Baseline
        self.label.fontSize = 25
        self.label.fontName = "System-Bold"
        self.label.name = "label"
    }

    /// days are rounded down
    private static func daysToDeadline(deadline: NSDate) -> Int {
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