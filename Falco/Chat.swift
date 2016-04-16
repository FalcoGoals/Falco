//
//  Chat.swift
//  Falco
//
//  Created by Lim Kiat on 15/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import SpriteKit

class Chat: SKNode {
    
    init (radius: CGFloat) {
        super.init()
        
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = UIColor.whiteColor()
        circle.name = "chat"
        let chat = SKSpriteNode(imageNamed: "chat")
        chat.size = CGSizeMake(radius * 1.5, radius * 1.5)
        chat.name = "chat"
        
        circle.addChild(chat)
        addChild(circle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}