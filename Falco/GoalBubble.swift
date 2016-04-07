//
//  GoalBubble.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import SpriteKit

protocol PresentationDelegate {
    func present(id: String?)
}

class GoalBubble: SKNode {
    var circle: SKShapeNode
    var label: SKLabelNode
    var id: String
    var delegate: PresentationDelegate!

    init(id: String, circleOfRadius: CGFloat, text: String) {
        self.id = id

        self.circle = SKShapeNode(circleOfRadius: circleOfRadius)
        self.circle.lineWidth = 1.5
        self.circle.physicsBody = SKPhysicsBody(circleOfRadius: circleOfRadius)
        self.circle.physicsBody?.allowsRotation = false
        self.circle.physicsBody?.restitution = 0.5
        self.circle.physicsBody?.friction = 0.0
        self.circle.physicsBody?.linearDamping = 0.1

        self.label = SKLabelNode(text: text)
        self.label.horizontalAlignmentMode = .Center
        self.label.verticalAlignmentMode = .Baseline
        self.label.fontSize = 15

        self.circle.addChild(self.label)

        super.init()
        self.userInteractionEnabled = true
        self.name = id
        addChild(self.circle)
    }

    convenience init(goal: Goal) {
        self.init(id: goal.id, circleOfRadius: CGFloat(goal.weight) / 2, text: goal.name)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first where touch.tapCount == 1 {
            delegate.present(self.id)
        }
    }
}