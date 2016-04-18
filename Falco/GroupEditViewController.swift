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
    @IBOutlet weak var tableView: UITableView!

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

        navigationItem.rightBarButtonItem = editButtonItem()
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
}

extension GroupEditViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FriendTableViewCell

        cell.toggleCheck()

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        setEditing(true, animated: true)
    }

    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        setEditing(false, animated: true)
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

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // update data
            group.removeMember(members[indexPath.row])
            delegate.didSaveGroup(group)

            // update view
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
    }
}
