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
    static let instance = Server()

    let ref = Firebase(url: "https://amber-torch-6648.firebaseio.com")
    var usersRef: Firebase!
    var groupsRef: Firebase!

    var user: User!
    var userRef: Firebase!

    var hasToken: Bool {
        if let token = currentAccessToken() {
            return token.hasGranted("user_friends")
        } else {
            return false
        }
    }

    var isAuth: Bool {
        return userRef != nil
    }

    private init() {
        usersRef = ref.childByAppendingPath("users")
        groupsRef = ref.childByAppendingPath("groups")
    }

    func auth(withCompletion completion: (() -> ())?) {
        if !hasToken {
            return
        }

        let token = currentAccessToken()!.tokenString
        ref.authWithOAuthProvider("facebook", token: token) {
            (error, authData) in
            if error != nil {
                print("Login failed. \(error)")
            } else {
                self.authSuccess(authData)
                completion?()
            }
        }
    }

    func getPersonalGoals(callback: (GoalCollection?) -> ()) {
        if !isAuth {
            callback(nil)
            return
        }

        let goalsRef = userRef.childByAppendingPath("goals")
        goalsRef.observeSingleEventOfType(.Value) { snapshot in
            callback(GoalCollection(goalsData: snapshot.value))
        }
    }

    func registerPersonalGoalsCallback(callback: (GoalCollection?) -> ()) {
        if !isAuth {
            callback(nil)
            return
        }

        let goalsRef = userRef.childByAppendingPath("goals")
        goalsRef.observeEventType(.Value) { snapshot in
            callback(GoalCollection(goalsData: snapshot.value))
        }
    }

    func savePersonalGoal(goal: PersonalGoal) -> Bool {
        if !isAuth {
            return false
        }

        let goalRef = userRef.childByAppendingPath("goals/\(goal.identifier)")
        goalRef.updateChildValues(goal.serialisedData)

        return true
    }

    func savePersonalGoals(goals: GoalCollection) -> Bool {
        if !isAuth {
            return false
        }

        for goal in goals.goals {
            if let goal = goal as? PersonalGoal {
                savePersonalGoal(goal)
            }
        }

        return true
    }

    func saveGroup(group: Group) -> Bool {
        if !isAuth {
            return false
        }

        let groupRef = groupsRef.childByAppendingPath(group.identifier)
        groupRef.updateChildValues(group.serialisedData)

        for member in group.members {
            let memberGroupsRef = usersRef.childByAppendingPath("\(member.identifier)/groups")
            memberGroupsRef.updateChildValues([group.identifier: "1"])
        }

        return true
    }

    private func authSuccess(authData: FAuthData) {
        print("Logged in as \(authData.providerData["displayName"]!)!")
        print("Profile picture: \(authData.providerData["profileImageURL"]!)")

        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "id, name, picture"])
        request.startWithCompletionHandler() { (connection, result, error) -> Void in
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            } else {
                let friends = result.valueForKey("data")! as! [[String: AnyObject]]
                print("Friends: \(friends)")

                let g1 = GroupGoal(name: "my task", details: "details", endTime: NSDate())
                let g2 = GroupGoal(name: "squad goal", details: "details", endTime: NSDate())

                g1.addUser(self.user)
                g2.addUser(self.user)

                var friendUsers = [User]()
                for friend in friends {
                    let uid = "facebook:\(friend["id"] as! String)"
                    let name = friend["name"] as! String
                    let friendUser = User(uid: uid, name: name)
                    friendUsers.append(friendUser)
                    g2.addUser(friendUser)
                }

                let goals = GoalCollection(goals: [g1, g2])

                let group = Group(creator: self.user, name: "\(self.user.name)'s test group", users: friendUsers)
                group.updateGoalCollection(goals)

                self.saveGroup(group)
            }
        }

        let uid = authData.uid
        let name = authData.providerData["displayName"] as! String
        user = User(uid: uid, name: name)
        userRef = usersRef.childByAppendingPath(uid)

        userRef.updateChildValues(["name": name])
    }

    private func currentAccessToken() -> FBSDKAccessToken? {
        return FBSDKAccessToken.currentAccessToken()
    }
}