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
    private var userGoalsRef: Firebase!
    private var userGroupsRef: Firebase!

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

        userGoalsRef.observeSingleEventOfType(.Value) { snapshot in
            callback(GoalCollection(goalsData: snapshot.value))
        }
    }

    func registerPersonalGoalsCallback(callback: (GoalCollection?) -> ()) {
        if !isAuth {
            callback(nil)
            return
        }

        userGoalsRef.observeEventType(.Value) { snapshot in
            callback(GoalCollection(goalsData: snapshot.value))
        }
    }

    func registerPersonalGoalAddCallback(callback: (PersonalGoal?) -> ()) {
        if !isAuth {
            callback(nil)
            return
        }

        userGoalsRef.observeEventType(.ChildAdded) {
            (snapshot: FDataSnapshot!) -> Void in
            let goalId = snapshot.key
            let goalData = snapshot.value as! [String : AnyObject]
            callback(PersonalGoal(id: goalId, goalData: goalData))
        }
    }

    func registerPersonalGoalUpdateCallback(callback: (PersonalGoal?) -> ()) {
        if !isAuth {
            callback(nil)
            return
        }

        userGoalsRef.observeEventType(.ChildChanged) {
            (snapshot: FDataSnapshot!) -> Void in
            let goalId = snapshot.key
            let goalData = snapshot.value as! [String : AnyObject]
            callback(PersonalGoal(id: goalId, goalData: goalData))
        }
    }

    func registerPersonalGoalRemoveCallback(callback: (PersonalGoal?) -> ()) {
        if !isAuth {
            callback(nil)
            return
        }

        userGoalsRef.observeEventType(.ChildRemoved) {
            (snapshot: FDataSnapshot!) -> Void in
            let goalId = snapshot.key
            let goalData = snapshot.value as! [String : AnyObject]
            callback(PersonalGoal(id: goalId, goalData: goalData))
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

    func saveGroupGoal(goal: GroupGoal) -> Bool {
        if !isAuth {
            return false
        }

        let goalRef = groupsRef.childByAppendingPath("\(goal.groupId)/goals/\(goal.id)")
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

        userGroupsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                callback(nil)
                return
            }

            let groupIdsDict = snapshot.value as! [String : AnyObject]
            var groups = [Group]()
            var groupIdsToBeRemoved = [String]()
            for (groupId, _) in groupIdsDict {
                let groupRef = self.groupsRef.childByAppendingPath(groupId)
                groupRef.observeSingleEventOfType(.Value, withBlock: { snapshot2 in
                    if let groupData = snapshot2.value as? [String: AnyObject] {
                        let group = Group(id: groupId, groupData: groupData)
                        if group.containsMember(self.user) {
                            groups.append(group)
                        } else {
                            groupIdsToBeRemoved.append(groupId)
                        }
                    } else {
                        groupIdsToBeRemoved.append(groupId)
                    }
                    if groups.count == groupIdsDict.keys.count - groupIdsToBeRemoved.count {
                        for groupIdToBeRemoved in groupIdsToBeRemoved {
                            self.userGroupsRef.updateChildValues([groupIdToBeRemoved: NSNull()])
                        }
                        callback(groups)
                        return
                    }
                })
            }
        })
    }

    func saveGroup(group: Group, withCompletion callback: (() -> ())? = nil) -> Bool {
        if !isAuth {
            return false
        }

        let groupRef = groupsRef.childByAppendingPath(group.id)
        groupRef.updateChildValues(group.serialisedData)

        for member in group.members {
            let memberGroupsRef = usersRef.childByAppendingPath("\(member.id)/groups")
            memberGroupsRef.updateChildValues([group.id: true]) {
                (error: NSError?, ref: Firebase!) in
                callback?()
            }
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
                let fbId = friendData["id"] as! String
                let id = "facebook:\(fbId)"
                let name = friendData["name"] as! String
                let pictureUrl = self.getPictureUrl(fbId)
                let friend = User(id: id, name: name, pictureUrl: pictureUrl)
                friends.append(friend)
            }
            callback(friends)
        }
    }

    private func authSuccess(authData: FAuthData) {
        let uid = authData.uid
        let fbId = authData.providerData["id"] as! String
        let name = authData.providerData["displayName"] as! String
        let pictureUrl = getPictureUrl(fbId)

        user = User(id: uid, name: name, pictureUrl: pictureUrl)
        userRef = usersRef.childByAppendingPath(uid)
        userRef.updateChildValues(["name": name])

        userGoalsRef = userRef.childByAppendingPath("goals")
        userGroupsRef = userRef.childByAppendingPath("groups")

        print("Logged in as: \(user)\n")
    }

    private func getPictureUrl(fbId: String) -> String {
        return fbId //"https://graph.facebook.com/\(fbId)/picture?width=70&height=70"
    }

    private func currentAccessToken() -> FBSDKAccessToken? {
        return FBSDKAccessToken.currentAccessToken()
    }
}