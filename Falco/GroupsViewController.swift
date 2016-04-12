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

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor(red: 13/255, green: 41/255, blue: 84/255, alpha: 0.7)
        cell.layer.cornerRadius = 30
        cell.layer.masksToBounds = true
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as! GroupTableViewCell

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
        bgColorView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        cell.selectedBackgroundView = bgColorView

        return cell
    }
}