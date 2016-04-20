//
//  MainViewController.swift
//  Falco
//
//  Created by John Yong on 8/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, LoginDelegate {
    private let server = Server.instance
    private let storage = Storage.instance

    private let background = UIImageView(image: UIImage(named: "wallpaper"))

    private var homeNavViewController: UINavigationController!
    private var homeViewController: BubblesViewController!
    private var groupsNavViewController: UINavigationController!
    private var groupsViewController: GroupsViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        homeNavViewController = viewControllers![0] as! UINavigationController
        homeViewController = homeNavViewController.topViewController as! BubblesViewController
        homeViewController.delegate = self

        groupsNavViewController = viewControllers![1] as! UINavigationController
        groupsViewController = groupsNavViewController.topViewController as! GroupsViewController
        groupsViewController.delegate = self

        view.insertSubview(background, atIndex: 0)

        if server.hasToken {
            didReceiveToken()
        }
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MainViewController.handleSwipe(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MainViewController.handleSwipe(_:)))
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }

    override func viewWillAppear(animated: Bool) {
        background.frame = view.frame
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        background.frame.size = size
    }

    override func viewDidAppear(animated: Bool) {
        if !server.hasToken {
            showLogin()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLogin" {
            let lvc = segue.destinationViewController as! LoginViewController
            lvc.delegate = self
        }
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .Left {
            selectedIndex = 1
        } else if sender.direction == .Right {
            selectedIndex = 0
        }
    }


    // MARK: LoginDelegate

    func didReceiveToken() {
        authAndDownloadGoals()
    }

    // MARK: Helper methods

    private func showLogin() {
        performSegueWithIdentifier("showLogin", sender: nil)
    }

    private func authAndDownloadGoals() {
        storage.loadFromCache()
        homeViewController.initialGoals = getAllGoals()?.relevantGoals
        let cacheDoesExist = !storage.personalGoals.isEmpty
        server.auth() {
            self.storage.user = self.server.user
            self.server.getPersonalGoals() { goals in
                if let goals = goals {
                    self.storage.personalGoals = goals
                    if !cacheDoesExist {
                        self.homeViewController.viewDidAppear(false)
                        self.updateBubblesView()
                    }
                    self.storage.writeToCache()
                }
            }
            self.server.getFriends() { friends in
                if let friends = friends {
                    for friend in friends {
                        self.storage.friends[friend.id] = friend
                    }
                    self.storage.isFriendListPopulated = true
                    self.storage.saveUsersData()
                    self.groupsViewController.refreshData()
                }
            }
        }
    }

    private func updateBubblesView() {
        homeViewController.addGoalsToScene(storage.personalGoals.incompleteGoals)
    }
}

extension MainViewController: ModelDelegate {

    func didUpdateGoal(goal: Goal) {
        if let goal = goal as? PersonalGoal {
            storage.personalGoals.updateGoal(goal)
            server.savePersonalGoal(goal)
        } else if let goal = goal as? GroupGoal {
            storage.groups[goal.groupId]!.goals.updateGoal(goal)
            server.saveGroupGoal(goal)
        }
    }

    func didCompleteGoal(goal: Goal) -> Goal? {
        if var pGoal = goal as? PersonalGoal {
            pGoal.markComplete()
            didUpdateGoal(pGoal)
            return pGoal
        } else if var gGoal = goal as? GroupGoal {
            gGoal.markCompleteByUser(storage.user)
            didUpdateGoal(gGoal)
            return gGoal
        } else {
            return nil
        }
    }

    func didCompleteGoal(goalId: String, groupId: String?) -> Goal? {
        if let goal = getGoal(goalId, groupId: groupId) {
            return didCompleteGoal(goal)
        } else {
            return nil
        }
    }

    func getGoal(goalId: String, groupId: String? = nil) -> Goal? {
        if let groupId = groupId {
            return storage.groups[groupId]?.goals.getGoalWithIdentifier(goalId)
        } else {
            return storage.personalGoals.getGoalWithIdentifier(goalId)
        }
    }

    func getGoals(groupId: String? = nil) -> GoalCollection? {
        if let groupId = groupId {
            return storage.groups[groupId]?.goals
        } else {
            return storage.personalGoals
        }
    }

    func getAllGoals() -> GoalCollection? {
        var allGoals = [Goal]()
        allGoals += storage.personalGoals.goals
        for group in storage.groups.values {
            allGoals += group.goals.goals
        }
        return GoalCollection(goals: allGoals)
    }

    func getGroup(groupId: String) -> Group? {
        return storage.groups[groupId]
    }

    func getGroups() -> [Group] {
        return Array(storage.groups.values)
    }

    func didUpdateGroup(group: Group, callback: (() -> ())? = nil) {
        storage.groups[group.id] = group
        server.saveGroup(group) {
            callback?()
        }
    }

    func refreshGroups(callback: (() -> ())? = nil) {
        server.getGroups() { groups in
            if let groups = groups {
                self.storage.groups = [:]
                for group in groups {
                    self.storage.groups[group.id] = group
                }
                self.storage.writeToCache()
            }
            callback?()
        }
    }
}
