//
//  GroupsViewController.swift
//  Falco
//
//  Created by Jing Yin Ong on 7/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GroupsViewController: UIViewController, GroupAddDelegate {
    private let searchController = UISearchController(searchResultsController: nil)

    private var _groups: [Group] {
        return delegate.getGroups()
    }
    private var _searchedGroups = [Group]()
    private var _selectedGroup: Group!

    var delegate: ModelDelegate!

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBarContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initSearchController()
        initTableView()
    }

    override func viewDidAppear(animated: Bool) {
        refreshData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.addGroupSegue {
            let nc = segue.destinationViewController as! UINavigationController
            let gavc = nc.topViewController as! GroupAddViewController
            gavc.delegate = self
        } else if segue.identifier == Constants.groupBubblesSegue {
            let bvc = segue.destinationViewController as! BubblesViewController
            bvc.title = _selectedGroup.name
            bvc.initialGoals = _selectedGroup.goals.incompleteGoals
            bvc.currentGroup = _selectedGroup
            bvc.delegate = delegate
        }
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let bar = searchController.searchBar
        bar.frame.size = CGSize(width: size.width, height: bar.frame.height)
        if tableView != nil {
            tableView.reloadData()
        }
    }

    func refreshData() {
        delegate.refreshGroups() {
            if self.tableView != nil {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: GroupAddDelegate

    func didAddGroup(group: Group) {
        delegate.didUpdateGroup(group) {
            self.refreshData()
        }
    }

    // MARK: IB Actions

    @IBAction func cancelGroupAdd(segue: UIStoryboardSegue) { }

    // MARK: Helper methods

    private func initSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Constants.groupSearchbarPlaceholder
        searchController.searchBar.barStyle = .Black
        definesPresentationContext = true
        searchBarContainer.addSubview(searchController.searchBar)
    }

    private func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionFooterHeight = Constants.groupFooterHeight
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -15)
    }

    private func filterContentForSearchText(searchText: String, scope: String = Constants.groupSearchScope) {
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
        if searchController.active && searchController.searchBar.text != Constants.emptyString {
            _selectedGroup = _searchedGroups[indexPath.section]
        } else {
            _selectedGroup = _groups[indexPath.section]
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier(Constants.groupBubblesSegue, sender: self)
    }
}

extension GroupsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active && searchController.searchBar.text != Constants.emptyString {
            return _searchedGroups.count
        }
        return _groups.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = Constants.groupCellBgColor
        cell.layer.cornerRadius = Constants.groupCellCornerRadius
        cell.layer.masksToBounds = true
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.groupCellID, forIndexPath: indexPath) as! GroupTableViewCell

        // init content of cell
        let selectedGroup: Group
        if searchController.active && searchController.searchBar.text != Constants.emptyString {
            selectedGroup = _searchedGroups[indexPath.section]
        } else {
            selectedGroup = _groups[indexPath.section]
        }
        cell.groupNameLabel?.text = selectedGroup.name

        cell.setPreviewGoals(selectedGroup.goals.incompleteGoals)

        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        cell.selectedBackgroundView = bgColorView

        return cell
    }
}