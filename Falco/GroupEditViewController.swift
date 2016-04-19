//
//  GroupEditViewController.swift
//  Falco
//
//  Created by Gerald on 17/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GroupEditViewController: UIViewController {
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    var group: Group!
    var delegate: Savable!

    private var checked: Set<User>!

    private var groupName: String {
        return group.name
    }
    private var otherMembers: [User] {
        return group.members.filter {
            return Storage.instance.user.id != $0.id
        }
    }
    private var otherMembersSet: Set<User> {
        return Set(otherMembers)
    }
    private var friends: [User] {
        return Storage.instance.friendsSortedByName
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        checked = Set(group.members)
        groupNameField.text = groupName
    }

    override func viewDidAppear(animated: Bool) {
        groupNameField.becomeFirstResponder()
    }

    @IBAction func leaveGroup(sender: UIButton) {
        group.removeMember(Storage.instance.user)
        delegate.didSaveGroup(group)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveGroup(sender: UIBarButtonItem) {
        for member in otherMembersSet.subtract(checked) {
            group.removeMember(member)
        }
        for member in checked.subtract(otherMembersSet) {
            group.addMember(member)
        }
        group.name = groupNameField.text!
        delegate.didSaveGroup(group)
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension GroupEditViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FriendTableViewCell
        cell.toggleCheck()

        let friend = friends[indexPath.row]
        if checked.contains(friend) {
            checked.remove(friend)
        } else {
            checked.insert(friend)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

extension GroupEditViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.groupMemberCellID, forIndexPath: indexPath) as! FriendTableViewCell

        guard otherMembers.count > 0 else {
            return cell
        }

        let friend = friends[indexPath.row]
        cell.setUser(friend)
        cell.accessoryType = otherMembersSet.contains(friend) ? .Checkmark : .None

        return cell
    }
}
