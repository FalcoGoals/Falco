//
//  AssignedUserTableViewCell.swift
//  Falco
//
//  Created by Lim Kiat on 16/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class AssignedUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
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
        nameLabel.text = user.name
    }
}