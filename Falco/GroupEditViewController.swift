//
//  GroupEditViewController.swift
//  Falco
//
//  Created by Gerald on 17/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GroupEditViewController: UIViewController {
    var group: Group {
        return delegate.getGroups().first!
    }
    var groupName: String {
        return group.name
    }
    var members: [User] {
        return group.members
    }

    var delegate: GroupModelDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension GroupEditViewController: UITableViewDelegate {

}

extension GroupEditViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.groupMemberCellID, forIndexPath: indexPath) as! FriendTableViewCell
        guard members.count > 0 else {
            return cell
        }

        //set image and name
        cell.setUser(members[indexPath.row])

        return cell
    }
}
