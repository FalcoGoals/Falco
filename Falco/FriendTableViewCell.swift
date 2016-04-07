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
    private var _user: User!
    var user: User? { return _user }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUser(user: User) {
        _user = user
        friendNameLabel.text = user.name
        let url = NSURL(string: user.pictureUrl)
        friendImageView.image = UIImage(data: NSData(contentsOfURL: url!)!)
    }
}