//
//  GroupsViewController.swift
//  Falco
//
//  Created by Jing Yin Ong on 7/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation
import UIKit

class GroupsViewController: UIViewController, GroupAddDelegate, GoalModelDelegate {
    private let searchController = UISearchController(searchResultsController: nil)

    private var server = Server.instance
    private var storage = Storage.instance

    private var _groups = [Group]()
    private var _searchedGroups = [Group]()
    private var _selectedGroup: Group!

    @IBOutlet var tableView: UITableView!
    private var numGoalPreview = 3
    
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
        } else if segue.identifier == "showGroupBubblesView" {
            let bvc = segue.destinationViewController as! BubblesViewController
            bvc.initialGoals = _selectedGroup.goals
            bvc.delegate = self
            if let _ = bvc.popoverPresentationController {
                bvc.preferredContentSize = view.frame.size
            }
        }
    }

    // MARK: GroupAddDelegate

    func didAddGroup(group: Group) {
        Server.instance.saveGroup(group) {
            self.refreshData()
        }
    }

    // MARK: GoalModelDelegate

    func didUpdateGoal(goal: Goal) {
        if let goal = goal as? PersonalGoal {
            storage.personalGoals.updateGoal(goal)
            server.savePersonalGoal(goal)
        }
        // TODO: group goals
    }

    func didCompleteGoal(goal: Goal) {
        if var pGoal = goal as? PersonalGoal {
            pGoal.markComplete()
            didUpdateGoal(pGoal)
        } else if var gGoal = goal as? GroupGoal {
            gGoal.markCompleteByUser(server.user)
            didUpdateGoal(gGoal)
        }
    }

    func getGoalWithIdentifier(goalId: String) -> Goal? {
        return _selectedGroup.goals.getGoalWithIdentifier(goalId)
    }

    func getGoals() -> GoalCollection {
        return _selectedGroup.goals.incompleteGoals
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

extension GroupsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchController.active && searchController.searchBar.text != "" {
            _selectedGroup = _searchedGroups[indexPath.row]
        } else {
            _selectedGroup = _groups[indexPath.row]
        }
        performSegueWithIdentifier("showGroupBubblesView", sender: self)
    }
}

extension GroupsViewController: UITableViewDataSource {
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
        // init layout params
        cell!.separatorInset = UIEdgeInsetsZero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.layoutMargins = UIEdgeInsetsZero
        cell!.backgroundColor = UIColor(red: 23, green: 72, blue: 147, alpha: 1)
        
        // init content of cell
        let selectedGroup: Group
        if searchController.active && searchController.searchBar.text != "" {
            selectedGroup = _searchedGroups[indexPath.row]
        } else {
            selectedGroup = _groups[indexPath.row]
        }
        cell!.groupNameLabel?.text = selectedGroup.name
        
        let goals = selectedGroup.goals
        goals.sortGoalsByPriority()
        var topGoalNames = [String]()
        for i in 0..<min(numGoalPreview, goals.count) {
            topGoalNames.append(goals.goals[i].name)
        }
        cell!.setPreviewGoalNames(topGoalNames)
        
        //let url = NSURL(string: _groups[indexPath.row].pictureUrl)
        //cell!.groupImageView?.image = UIImage(data: NSData(contentsOfURL: url!)!)
        return cell!
    }
}