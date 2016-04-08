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
    private var _searchedGroups = [Group]()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        Server.instance.getGroups() { data in
            if let groups = data {
                self._groups.appendContentsOf(groups)
                self.tableView.reloadData()
            }
        }
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        _searchedGroups = _groups.filter { group in
            return group.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return _searchedGroups.count
        }
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
        let selectedGroup: Group
        if searchController.active && searchController.searchBar.text != "" {
            selectedGroup = _searchedGroups[indexPath.row]
        } else {
            selectedGroup = _groups[indexPath.row]
        }
        cell!.groupNameLabel?.text = selectedGroup.name
        //let url = NSURL(string: _groups[indexPath.row].pictureUrl)
        //cell!.groupImageView?.image = UIImage(data: NSData(contentsOfURL: url!)!)
        return cell!
    }
}


extension GroupsViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}