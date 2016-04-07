//
//  BubblesScene.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import SpriteKit

class BubblesScene: SKScene {
    private var cam: SKCameraNode!
    private var cameraMoved = false

    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPointMake (0.0,1.0)
        cam = SKCameraNode()
        camera = cam
        cam.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        addChild(cam)
        
        let points = [CGPointMake(0, -9999), CGPointMake(0, 0), CGPointMake(size.width,0), CGPointMake(size.width, -9999)]
        let screenPath = CGPathCreateMutable()
        CGPathAddLines(screenPath, nil, points, 4)
        
        physicsBody = SKPhysicsBody(edgeChainFromPath: screenPath)
        physicsWorld.gravity = CGVectorMake(0, 4)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        
        //            goal.position = CGPointMake(CGFloat(x), CGFloat(y) - 100)
        //            let actionMove = SKAction.moveTo(CGPointMake(CGFloat(x), CGFloat(y)), duration: 2)
        //            goal.runAction(actionMove)
//        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
//        self.physicsWorld.gravity = CGVectorMake(0, 4)
    }
    
      override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        cameraMoved = true
        let touch = touches.first
        let positionInScene = touch!.locationInNode(self)
        let previousPosition = touch!.previousLocationInNode(self)
        let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
        if (cam.position.y - translation.y > -frame.height/2) {
            cam.position.y = -frame.height/2
        } else {
            cam.position.y -= translation.y
        }
//        cam.position.x -= translation.x
//        cam.position.y -= translation.y
      }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (cameraMoved) {
            cameraMoved = false
        } else {
            addNewBubble()
        }
    }
    
    func addNewBubble() {
        let goal = PersonalGoal(name: "New", details: "my goal", priority: .High, endTime: NSDate())
        //addGoal(goal)
    }

    func addGoal(goal: GoalBubble) {
        //physicsWorld.gravity = CGVectorMake(0, 0)
        addChild(goal)
    }
}
