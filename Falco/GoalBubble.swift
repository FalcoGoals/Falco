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
        self.label = SKLabelNode(text: text)

        super.init()

        addChild(self.circle)
        addChild(self.label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
