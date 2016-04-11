//
//  BubbleCell.swift
//  Falco
//
//  Created by Gerald on 16/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class BubbleCell: UIView {
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = self.frame.size.width/2
        clipsToBounds = true
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 2.0
        backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        label = UILabel(frame: CGRectMake(0, 0, frame.size.width, frame.size.width))
        label.center = CGPointMake(frame.size.width/2, frame.size.width/2)
        label.textAlignment = NSTextAlignment.Center
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
