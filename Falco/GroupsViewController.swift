//
//  GroupsViewController.swift
//  Falco
//
//  Created by Jing Yin Ong on 7/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation
import UIKit

class GroupsViewController: UIViewController, GroupAddDelegate {
    private var _groups = [Group]()
    private var _searchedGroups = [Group]()
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        initSearchController()
        initTableView()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGroupAdd" {
            let gavc = segue.destinationViewController as! GroupAddViewController
            gavc.delegate = self
        }
    }

    // MARK: GroupAddDelegate

    func didAddGroup(group: Group) {
        Server.instance.saveGroup(group) {
            self.refreshData()
        }
    }

    // MARK: Helper methods
    
    private func initSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find a group"
        //searchController.searchBar.barStyle = UIBarStyle.Black
        definesPresentationContext = true
    }
    
    private func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.separatorColor = UIColor.whiteColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    private func refreshData() {
        Server.instance.getGroups() { data in
            if let groups = data {
                self._groups = groups
                self.tableView.reloadData()
            }
        }
    }
    
    private func filterContentForSearchText(searchText: String, scope: String = "All") {
        _searchedGroups = _groups.filter { group in
            return group.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
}

extension GroupsViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension GroupsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return _searchedGroups.count
        }
        return _groups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as? GroupTableViewCell
        if cell == nil {
            cell = GroupTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "groupCell")
        }
        cell!.separatorInset = UIEdgeInsetsZero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.layoutMargins = UIEdgeInsetsZero
        cell!.backgroundColor = UIColor(red: 23, green: 72, blue: 147, alpha: 1)
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