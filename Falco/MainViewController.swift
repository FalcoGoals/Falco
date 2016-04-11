//
//  MainViewController.swift
//  Falco
//
//  Created by John Yong on 8/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, LoginDelegate, GoalModelDelegate {
    private var server = Server.instance
    private var storage = Storage.instance

    private var homeViewController: BubblesViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        homeViewController = viewControllers![0] as! BubblesViewController
        homeViewController.delegate = self

        if server.hasToken {
            didReceiveToken()
        }
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

    // MARK: LoginDelegate

    func didReceiveToken() {
        authAndDownloadGoals()
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
        return storage.personalGoals.getGoalWithIdentifier(goalId)
        // TODO: group goals
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
