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

        let goalRef = userRef.childByAppendingPath("goals/\(goal.id)")
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
            let memberGroupsRef = usersRef.childByAppendingPath("\(member.id)/groups")
            memberGroupsRef.updateChildValues([group.identifier: true])
        }

        return true
    }

    func getFriends(callback: ([User]?) -> ()) {
        if !isAuth {
            callback(nil)
            return
        }

        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "id, name, picture"])
        request.startWithCompletionHandler() { (connection, result, error) -> Void in
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
                callback(nil)
                return
            }

            var friends = [User]()
            let friendsData = result.valueForKey("data")! as! [[String: AnyObject]]
            for friendData in friendsData {
                let id = "facebook:\(friendData["id"] as! String)"
                let name = friendData["name"] as! String
                let pictureData = (friendData["picture"] as! [String: AnyObject])["data"] as! [String: AnyObject]
                let pictureUrl = pictureData["url"] as! String
                let friend = User(id: id, name: name, pictureUrl: pictureUrl)
                friends.append(friend)
            }

            print("Friends: \(friends)")
            callback(friends)
        }
    }

    private func authSuccess(authData: FAuthData) {
        let uid = authData.uid
        let name = authData.providerData["displayName"] as! String
        let pictureUrl = authData.providerData["profileImageURL"] as! String

        user = User(id: uid, name: name, pictureUrl: pictureUrl)
        userRef = usersRef.childByAppendingPath(uid)
        userRef.updateChildValues(["name": name])

        print("Logged in as: \(user)")
    }

    private func currentAccessToken() -> FBSDKAccessToken? {
        return FBSDKAccessToken.currentAccessToken()
    }
}