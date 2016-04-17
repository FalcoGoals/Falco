//
//  GroupEditViewController.swift
//  Falco
//
//  Created by Gerald on 17/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GroupEditViewController: UIViewController {
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

        print(group)
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
//        cell.setUser(members[indexPath.row])
        let stubMember = User(id: "awdawd", name: "fOoo", pictureUrl: "https://scontent.xx.fbcdn.net/hprofile-frc1/v/t1.0-1/p100x100/10418966_10152342769803655_3656733882909337602_n.jpg?oh=4354526ff1cea06d54d96e4752bef323&oe=5772A9B9")

        cell.setUser(stubMember)


        return cell
    }
}
