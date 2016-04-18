//
//  GroupEditViewController.swift
//  Falco
//
//  Created by Gerald on 17/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GroupEditViewController: UIViewController {
    @IBOutlet weak var groupNameLabel: UILabel!

    var group: Group!
    var delegate: Savable!

    private var groupName: String {
        return group.name
    }
    private var members: [User] {
        return group.members
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        groupNameLabel.text = groupName
    }
}

extension GroupEditViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FriendTableViewCell

        cell.toggleCheck()

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
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

        cell.setUser(members[indexPath.row])
        return cell
    }
}
