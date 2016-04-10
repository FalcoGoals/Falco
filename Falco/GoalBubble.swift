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
    var label: SKLabelNode

    init(id: String, circleOfRadius: CGFloat, text: String, deadline: NSDate) {
        self.id = id
        self.circle = SKShapeNode(circleOfRadius: circleOfRadius)
        self.label = SKLabelNode(text: text)

        super.init()

        self.userInteractionEnabled = true
        self.name = id

        self.circle.lineWidth = 2
        if let aShadeOfRed = UIColor.redColor().desaturate(times: daysToDeadline(deadline)) {
            self.circle.strokeColor = aShadeOfRed
        }

        self.circle.physicsBody = SKPhysicsBody(circleOfRadius: circleOfRadius)
        self.circle.physicsBody?.allowsRotation = false
        self.circle.physicsBody?.restitution = 0.5
        self.circle.physicsBody?.friction = 0.0
        self.circle.physicsBody?.linearDamping = 0.1

        self.label.horizontalAlignmentMode = .Center
        self.label.verticalAlignmentMode = .Baseline
        self.label.fontSize = 25
        self.label.fontName = "System-Bold"

        self.circle.addChild(self.label)

        addChild(self.circle)
    }

    convenience init(goal: Goal) {
        self.init(id: goal.id, circleOfRadius: CGFloat(goal.weight) / 2, text: goal.name, deadline: goal.endTime)
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
}

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

        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
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