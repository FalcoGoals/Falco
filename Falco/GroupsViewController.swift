//
//  GroupsViewController.swift
//  Falco
//
//  Created by Jing Yin Ong on 7/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation
import UIKit

class GroupsViewController: UITableViewController {
    private var _groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Server.instance.getGroups() { data in
            if let groups = data {
                self._groups.appendContentsOf(groups)
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _groups.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as? GroupTableViewCell
        if cell == nil {
            cell = GroupTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "groupCell")
        }
        cell!.separatorInset = UIEdgeInsetsZero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.layoutMargins = UIEdgeInsetsZero
        cell!.groupNameLabel?.text = _groups[indexPath.row].name
        //let url = NSURL(string: _groups[indexPath.row].pictureUrl)
        //cell!.groupImageView?.image = UIImage(data: NSData(contentsOfURL: url!)!)
        return cell!
    }
    
    


}