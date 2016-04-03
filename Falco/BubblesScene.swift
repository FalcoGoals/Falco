//
//  BubblesScene.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import SpriteKit

class BubblesScene: SKScene {
    let background = SKSpriteNode(imageNamed: "BubbleBackground.jpg")
    var cam:SKCameraNode!
    private var goalModel = GoalCollection(goals: [])
    var circlePosition = [[Int]]()
    var lowestY = 0
    var moved = false

    init(size: CGSize, goalModel: GoalCollection) {
        super.init(size: size)
        self.goalModel = goalModel
        
        self.anchorPoint = CGPointMake (0.0,1.0)
        
        self.background.size.width = size.width
        self.background.name = "background"
        self.background.anchorPoint = CGPointMake (0.0,1.0)
        self.background.physicsBody?.dynamic = false
        self.background.zPosition = -1.0
        self.addChild(background)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        cam = SKCameraNode() //initialize and assign an instance of SKCameraNode to the cam variable.
        
        self.camera = cam //set the scene's camera to reference cam
        self.addChild(cam) //make the cam a childElement of the scene itself.
        
        //position the camera on the gamescene.
        cam.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        //cam.physicsBody?.dynamic = false
        
        let points = [CGPointMake(0, -9999), CGPointMake(0, 0), CGPointMake(size.width,0), CGPointMake(size.width, -9999)]
        let screenPath = CGPathCreateMutable()
        CGPathAddLines(screenPath, nil, points, 4)
        
        self.physicsBody = SKPhysicsBody(edgeChainFromPath: screenPath)
        self.physicsWorld.gravity = CGVectorMake(0, 4)
        var offset = CGFloat(100)

        for goal in goalModel.goals {
            let weight = goal.weight
            let (x,y) = calculateNextPosition(weight)
            let goal = GoalBubble(circleOfRadius: CGFloat(weight)/2, text: goal.name)
            if (y - weight/2 < lowestY) {
                lowestY = y - weight/2
            }
            circlePosition.append([x, y, weight])
            goal.position = CGPointMake(CGFloat(x), CGFloat(y) - offset)
            offset += 50
            
//            goal.position = CGPointMake(CGFloat(x), CGFloat(y) - 100)
//            let actionMove = SKAction.moveTo(CGPointMake(CGFloat(x), CGFloat(y)), duration: 2)
//            goal.runAction(actionMove)
            addChild(goal)
        }
    }
    
      override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        moved = true
        let touch = touches.first
        let positionInScene = touch!.locationInNode(self)
        let previousPosition = touch!.previousLocationInNode(self)
        let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
        cam.position.x -= translation.x
        cam.position.y -= translation.y
      }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (moved) {
            moved = false
        } else {
            
        }
    }
    
    func boundLayerPos(aNewPosition : CGPoint) -> CGPoint {
        var retval = aNewPosition
        retval.y = CGFloat(max(retval.y, 0))
        retval.x = self.position.x
        
        return retval
    }
    
    func panForTranslation(translation : CGPoint) {
        let position = background.position
    
        let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
        background.position = self.boundLayerPos(aNewPosition)
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
        
        print(lowestYValue)
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
