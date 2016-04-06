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
    private let ref = Firebase(url: "https://amber-torch-6648.firebaseio.com")
    private var usersRef: Firebase!
    private var groupsRef: Firebase!
    private var userRef: Firebase!

    static let instance = Server()

    var user: User!

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

    func getGroups(callback: ([Group]?) -> ()) {
        if !isAuth {
            callback(nil)
            return
        }

        let userGroupsRef = userRef.childByAppendingPath("groups")
        userGroupsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                callback(nil)
                return
            }

            let groupIdsDict = snapshot.value as! [String : AnyObject]
            var groups = [Group]()
            for (groupId, _) in groupIdsDict {
                let groupRef = self.groupsRef.childByAppendingPath(groupId)
                groupRef.observeSingleEventOfType(.Value, withBlock: { snapshot2 in
                    let groupData = snapshot2.value as! [String: AnyObject]
                    groups.append(Group(id: groupId, groupData: groupData))
                    if groups.count == groupIdsDict.keys.count {
                        callback(groups)
                        return
                    }
                })
            }
        })
    }

    func saveGroup(group: Group) -> Bool {
        if !isAuth {
            return false
        }

        let groupRef = groupsRef.childByAppendingPath(group.id)
        groupRef.updateChildValues(group.serialisedData)

        for member in group.members {
            let memberGroupsRef = usersRef.childByAppendingPath("\(member.id)/groups")
            memberGroupsRef.updateChildValues([group.id: true])
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