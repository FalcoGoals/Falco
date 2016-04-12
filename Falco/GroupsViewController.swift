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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        initSearchController()
        initTableView()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGroupAdd" {
            let nc = segue.destinationViewController as! UINavigationController
            let gavc = nc.topViewController as! GroupAddViewController
            gavc.delegate = self
        } else if segue.identifier == "showGroupBubblesView" {
            let bvc = segue.destinationViewController as! BubblesViewController
            bvc.title = _selectedGroup.name
            bvc.initialGoals = _selectedGroup.goals
            bvc.delegate = self
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

    // MARK: IB Actions

    @IBAction func cancelGroupAdd(segue: UIStoryboardSegue) { }

    // MARK: Helper methods
    
    private func initSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find a group"
        searchController.searchBar.barStyle = .Black
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as! GroupTableViewCell

        // init layout params
//        cell.separatorInset = UIEdgeInsetsZero
//        cell.preservesSuperviewLayoutMargins = false
//        cell.layoutMargins = UIEdgeInsetsZero

        // init content of cell
        let selectedGroup: Group
        if searchController.active && searchController.searchBar.text != "" {
            selectedGroup = _searchedGroups[indexPath.row]
        } else {
            selectedGroup = _groups[indexPath.row]
        }
        cell.groupNameLabel?.text = selectedGroup.name

        cell.setPreviewGoals(selectedGroup.goals)

        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 23/255, green: 72/255, blue: 147/255, alpha: 1)
        bgColorView.alpha = 0.5
        cell.selectedBackgroundView = bgColorView
        
        //let url = NSURL(string: _groups[indexPath.row].pictureUrl)
        //cell!.groupImageView?.image = UIImage(data: NSData(contentsOfURL: url!)!)
        return cell
    }
}