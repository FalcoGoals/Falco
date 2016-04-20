//
//  Chat.swift
//  Falco
//
//  Created by Lim Kiat on 15/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import SpriteKit

class ChatBubble: SKNode {
    
    init (radius: CGFloat) {
        super.init()
        
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = UIColor.whiteColor()
        circle.name = Constants.chatName
        let chat = SKSpriteNode(imageNamed: "chat")
        chat.size = CGSize(width: radius * Constants.chatScaleFactor, height: radius * Constants.chatScaleFactor)
        chat.name = Constants.chatName
        
        circle.addChild(chat)
        addChild(circle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}