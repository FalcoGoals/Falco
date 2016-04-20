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
    private var chatBubble: ChatBubble?

    private var circlePosition = [[Int]]()
    private var lowestY = Constants.lowestYValue
    private var offset = Constants.bubbleOffsetValue

    private var screenPath: CGMutablePath {
        let points = [CGPointMake(0, Constants.lowestPathPoint), CGPointMake(0, 0),
                      CGPointMake(size.width, 0), CGPointMake(size.width, Constants.lowestPathPoint)]
        let path = CGPathCreateMutable()
        CGPathAddLines(path, nil, points, 4)
        return path
    }

    override init(size: CGSize) {
        super.init(size: size)

        anchorPoint = CGPointMake(0.0, 1.0)
        scaleMode = .ResizeFill
        backgroundColor = UIColor.clearColor()
        
        cam = SKCameraNode()
        cam.position = CGPoint(x: frame.midX, y: frame.midY)
        cam.name = "camera"
        addChild(cam)
        camera = cam
        
        physicsBody = SKPhysicsBody(edgeChainFromPath: screenPath)
        physicsWorld.gravity = CGVectorMake(0, 4)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Repositions the camera and chatBubble when orientation(size) changes
    override func didChangeSize(oldSize: CGSize) {
        physicsBody = SKPhysicsBody(edgeChainFromPath: screenPath)
        cam?.position = CGPoint(x: frame.midX, y: frame.midY)
        chatBubble?.position = CGPointMake(size.width/2 - Constants.chatBubbleOffset,
                                           (-size.height/2) + Constants.chatBubbleOffset)
    }

    /// Allows for panning of camera in y direction (cannot go further top than first bubble)
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let positionInScene = touch!.locationInNode(self)
        let previousPosition = touch!.previousLocationInNode(self)
        let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
        if cam.position.y - translation.y > -frame.height/2 {
            cam.position.y = -frame.height/2
        } else {
            cam.position.y -= translation.y
        }
    }

    /// Adds goal based on calculated next position, and with an offset of the y value to make bubble rise from top
    func addGoal(goal: Goal) {
        let weight = goal.weight
        let (x,y) = calculateNextPosition(weight)
        if y - weight/2 < lowestY {
            lowestY = y - weight/2
        }
        circlePosition.append([x, y, weight])
        let goalBubble = GoalBubble(goal: goal)
        goalBubble.position = CGPointMake(CGFloat(x), CGFloat(y) - offset)
        offset += Constants.bubbleOffsetIncrement
        addChild(goalBubble)
    }

    func addGoals(goals: GoalCollection) {
        circlePosition.removeAll()
        lowestY = Constants.lowestYValue
        offset = Constants.bubbleOffsetValue
        for goal in goals.goals {
            runAction(SKAction.sequence([
                SKAction.waitForDuration(0.5),
                SKAction.runBlock({self.addGoal(goal)})
                ]))
        }
    }

    func updateGoal(goal: Goal) {
        if let goalNode = childNodeWithName("//\(goal.id)") as? GoalBubble {
            goalNode.updateWithGoal(goal)
        } else {
            addGoal(goal)
        }
    }
    
    func addChatBubble() {
        chatBubble = ChatBubble(radius: Constants.chatBubbleRadius)
        chatBubble!.position = CGPointMake(size.width/2 - Constants.chatBubbleOffset,
                                           (-size.height/2) + Constants.chatBubbleOffset)
        cam.addChild(chatBubble!)
    }
    
    /// Calculates approximately where the next bubble should be placed in scene
    private func calculateNextPosition(diameter: Int) -> (Int, Int){
        var xValue = 0
        var lowestYValue = lowestY
        let maxXValue = Int(size.width) - diameter


        for currX in 0..<maxXValue {
            var currY = lowestYValue
            var intersection = false
            while currY < 0 {
                for circle in circlePosition {
                    if (circleIntersection(circle[0], y1: circle[1],
                        r1: circle[2]/2, x2: currX+diameter/2, y2: currY+diameter/2, r2: diameter/2)) {
                        intersection = true
                        break
                    }
                }
                if intersection {
                    break
                } else {
                    currY += 1
                }
            }
            if currY > lowestYValue {
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

        if distance <= Double(r1) + Double(r2) {
            return true
        } else {
            return false
        }
    }
}
