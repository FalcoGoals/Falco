//
//  BubbleCell.swift
//  Pegasus
//
//  Created by Gerald on 16/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class BubbleCell: UICollectionViewCell {
  @IBOutlet var label: UILabel!
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    // configure the aesthetics of the bubble
    contentView.layer.borderColor = UIColor.whiteColor().CGColor
    contentView.layer.borderWidth = CGFloat(1)
    contentView.backgroundColor = UIColor.whiteColor()
  }
}
