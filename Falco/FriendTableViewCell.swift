//
//  FriendTableViewCell.swift
//  Falco
//
//  Created by Jing Yin Ong on 6/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation
import UIKit

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}