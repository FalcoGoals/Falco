//
//  GroupAddViewController.swift
//  Falco
//
//  Created by Jing Yin Ong on 6/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation
import UIKit

class GroupAddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var tableView: UITableView!
    
    private var groupName: String?
    private var friends = [User]()//Server.instance.getFriends()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let a = User(id: "1", name: "abalone", pictureUrl: "fjdk.jpg")
        let b = User(id: "2", name: "batman", pictureUrl: "fd.png")
        friends.append(a)
        friends.append(b)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func createGroup(sender: AnyObject) {
        if let name = nameInput.text {
            groupName = name
            
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as? FriendTableViewCell
        if cell == nil {
            cell = FriendTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "friendCell")
        }
        cell!.separatorInset = UIEdgeInsetsZero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.layoutMargins = UIEdgeInsetsZero
        cell!.friendNameLabel?.text = friends[indexPath.row].name
        if cell!.friendNameLabel == nil {
            print("friend name label doesnt exist")
        }
        print(friends[indexPath.row].name)
        //cell.friendImageView =
        return cell!
    }
    
}