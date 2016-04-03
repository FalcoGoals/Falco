//
//  GoalBubble.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import SpriteKit

class GoalBubble: SKNode {
    var circle: SKShapeNode
    var label: SKLabelNode

    init(circleOfRadius: CGFloat, text: String) {
        self.circle = SKShapeNode(circleOfRadius: circleOfRadius)
        self.circle.lineWidth = 1.5
        self.circle.physicsBody = SKPhysicsBody(circleOfRadius: circleOfRadius)
        self.circle.physicsBody?.allowsRotation = false
        self.circle.physicsBody?.friction = 0
        self.circle.fillColor = UIColor.blueColor()

        self.label = SKLabelNode(text: text)
        self.label.horizontalAlignmentMode = .Center
        self.label.verticalAlignmentMode = .Baseline

        super.init()

        self.circle.addChild(self.label)
        addChild(self.circle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
