//
//  MainViewController.swift
//  Falco
//
//  Created by John Yong on 8/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, LoginDelegate {
    private var server = Server.instance
    private var storage = Storage.instance

    private var homeNavViewController: UINavigationController!
    private var homeViewController: BubblesViewController!
    private var groupsNavViewController: UINavigationController!
    private var groupsViewController: GroupsViewController!

    private var background = UIImageView(image: UIImage(named: "wallpaper"))

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
        if (sender.direction == .Left) {
            selectedIndex = 1
        }
        
        if (sender.direction == .Right) {
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
        server.auth() {
            self.server.getPersonalGoals() { goals in
                if let goals = goals {
                    self.storage.personalGoals = goals
                    self.updateBubblesView()
                }
            }
            self.server.getFriends() { friends in
                if let friends = friends {
                    self.storage.friends = friends
                }
            }
        }
    }

    private func updateBubblesView() {
        homeViewController.addGoalsToScene(storage.personalGoals.incompleteGoals)
    }
}

extension MainViewController: GoalModelDelegate {

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
        return storage.personalGoals.getGoalWithIdentifier(goalId)
        // TODO: group goals
    }

    func getGoals() -> GoalCollection {
        return storage.personalGoals.incompleteGoals
    }
}

extension MainViewController: GroupModelDelegate {

    func getGroups() -> [Group] {
        return storage.groups
    }

    func didUpdateGroup(group: Group) {
        for i in 0..<storage.groups.count {
            let existingGroup = storage.groups[i]
            if existingGroup.id == group.id {
                storage.groups[i] = group
                // TODO: update server
                return
            }
        }
    }

    func didAddGroup(group: Group, callback: (() -> ())? = nil) {
        storage.groups.append(group)
        server.saveGroup(group) {
            callback?()
        }
    }

    func refreshGroups(callback: (() -> ())? = nil) {
        server.getGroups() { groups in
            if let groups = groups {
                self.storage.groups = groups
            }
            callback?()
        }
    }
}
