//
//  GroupChatViewController.swift
//  Falco
//
//  Created by Jing Yin Ong on 2/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation
import UIKit

class GroupChatViewController: UIViewController {
    var groupName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = groupName
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
}