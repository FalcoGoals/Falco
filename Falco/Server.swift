//
//  Server.swift
//  Falco
//
//  Created by John Yong on 28/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Firebase
import FBSDKLoginKit

class Server {
    let ref = Firebase(url: "https://amber-torch-6648.firebaseio.com")
    var usersRef: Firebase!
    var groupsRef: Firebase!

    var user: User!
    var userRef: Firebase!

    var hasToken: Bool {
        return currentAccessToken() != nil
    }

    var isAuth: Bool {
        return userRef != nil
    }

    init() {
        usersRef = ref.childByAppendingPath("users")
        groupsRef = ref.childByAppendingPath("groups")
    }

    func auth(callback: () -> ()) {
        if let accessToken = currentAccessToken()?.tokenString {
            ref.authWithOAuthProvider("facebook", token: accessToken) {
                (error, authData) in
                if error != nil {
                    print("Login failed. \(error)")
                } else {
                    self.authSuccess(authData)
                    callback()
                }
            }
        }
    }

    func getPersonalGoals(callback: (GoalCollection?) -> ()) {
        if !isAuth {
            print("Not logged in!")
            callback(nil)
            return
        }

        var goals = [Goal]()

        let goalsRef = userRef.childByAppendingPath("goals")
        goalsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                callback(GoalCollection(goals: goals))
                return
            }
            let goalsData = snapshot.value as! [String: NSDictionary]
            for (goalId, goalData) in goalsData {
                let isCompleted = goalData["isCompleted"]! as! Bool
                let name = goalData["name"]! as! String
                let details = goalData["details"]! as! String
                let endTime = NSDate(timeIntervalSinceReferenceDate: NSTimeInterval(goalData["endTime"] as! NSNumber))
                let priority = PriorityType(rawValue: goalData["priority"]! as! Int)!

                let goal = PersonalGoal(user: self.user, uid: goalId, name: name, details: details, endTime: endTime, priority: priority)
                if isCompleted {
                    goal.markAsComplete()
                }

                goals.append(goal)
            }

            callback(GoalCollection(goals: goals))

            }, withCancelBlock: { error in
                print(error.description)
        })
    }

    func savePersonalGoal(goal: PersonalGoal) -> Bool {
        if !isAuth {
            return false
        }

        let goalRef = userRef.childByAppendingPath("goals/\(goal.identifier)")
        goalRef.childByAppendingPath("isCompleted").setValue(goal.isCompleted)
        goalRef.childByAppendingPath("name").setValue(goal.name)
        goalRef.childByAppendingPath("details").setValue(goal.details)
        goalRef.childByAppendingPath("endTime").setValue(goal.endTime.timeIntervalSince1970)
        goalRef.childByAppendingPath("priority").setValue(goal.priority.rawValue)
        if let completionTime = goal.timeOfCompletion?.timeIntervalSince1970 {
            goalRef.childByAppendingPath("timeOfCompletion").setValue(completionTime)
        }
        return true
    }

    private func authSuccess(authData: FAuthData) {
        print("Logged in as \(authData.providerData["displayName"]!)!")

        let uid = authData.uid
        let name = authData.providerData["displayName"] as! String
        user = User(uid: uid, name: name)
        userRef = ref.childByAppendingPath("users/\(uid)")

        userRef.updateChildValues(["name": name])
    }

    private func currentAccessToken() -> FBSDKAccessToken? {
        return FBSDKAccessToken.currentAccessToken()
    }
}