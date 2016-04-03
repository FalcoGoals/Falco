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

        let goalsRef = userRef.childByAppendingPath("goals")
        goalsRef.observeSingleEventOfType(.Value) { snapshot in
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