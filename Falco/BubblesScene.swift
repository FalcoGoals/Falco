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

    private var circlePosition = [[Int]]()
    private var lowestY = 0
    private var offset = CGFloat(100)

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

//    override func didMoveToView(view: SKView) {

        //            goal.position = CGPointMake(CGFloat(x), CGFloat(y) - 100)
        //            let actionMove = SKAction.moveTo(CGPointMake(CGFloat(x), CGFloat(y)), duration: 2)
        //            goal.runAction(actionMove)
//        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
//        self.physicsWorld.gravity = CGVectorMake(0, 4)
//    }

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
//            addNewBubble()
        }
    }
    
//    func addNewBubble() {
//        let goal = PersonalGoal(name: "New", details: "my goal", priority: .High, endTime: NSDate())
        //addGoal(goal)
//    }

    func addGoalBubble(goalBubble: GoalBubble) {
        //physicsWorld.gravity = CGVectorMake(0, 0)
        addChild(goalBubble)
    }

    func addGoals(goals: GoalCollection, delegate: PresentationDelegate) {
        for goal in goals.goals {
            let weight = goal.weight
            let (x,y) = calculateNextPosition(weight)
            let goalBubble = GoalBubble(id: goal.id,circleOfRadius: CGFloat(weight)/2, text: goal.name)
            goalBubble.delegate = delegate
            if (y - weight/2 < lowestY) {
                lowestY = y - weight/2
            }
            circlePosition.append([x, y, weight])
            goalBubble.position = CGPointMake(CGFloat(x), CGFloat(y) - offset)
            offset += 50
            addGoalBubble(goalBubble)
        }
    }

    private func calculateNextPosition(diameter: Int) -> (Int, Int){
        var xValue = 0
        var lowestYValue = lowestY
        let maxXValue = Int(size.width) - diameter


        for currX in 0..<maxXValue {
            var currY = lowestYValue
            var intersection = false
            while (currY < 0) {
                for circle in circlePosition {
                    if (circleIntersection(circle[0], y1: circle[1],
                        r1: circle[2]/2, x2: currX+diameter/2, y2: currY+diameter/2, r2: diameter/2)) {
                        intersection = true
                        break
                    }
                }
                if (intersection) {
                    break
                } else {
                    currY += 1
                }
            }
            if (currY > lowestYValue) {
                xValue = currX
                lowestYValue = currY
            }
        }

        return (xValue + diameter/2, lowestYValue - diameter/2)
    }

    private func circleIntersection(x1: Int, y1: Int, r1: Int, x2: Int, y2: Int, r2: Int) -> Bool {
        let dx = Double(x1) - Double(x2);
        let dy = Double(y1) - Double(y2);
        let distance = sqrt(dx * dx + dy * dy);

        if distance <= (Double(r1) + Double(r2)) {
            return true
        } else {
            return false
        }
    }
}
