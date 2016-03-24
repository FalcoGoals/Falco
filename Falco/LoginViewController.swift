//
//  LoginViewController.swift
//  Falco
//
//  Created by John Yong on 20/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {
    @IBOutlet var loginButton: UIButton!

    let ref = Firebase(url: "https://amber-torch-6648.firebaseio.com")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        attemptLogin()
    }

    override func viewDidAppear(animated: Bool) {
        if currentAccessToken() != nil {
            self.loginButton.titleLabel?.text = "Logging in..."
        }
    }

    @IBAction func loginTapped(sender: AnyObject) {
        FBSDKLoginManager().logInWithReadPermissions(["email"], fromViewController: self) {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                self.loginButton.titleLabel?.text = "Login with Facebook"
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
                self.loginButton.titleLabel?.text = "Login with Facebook"
            } else {
                self.loginButton.titleLabel?.text = "Login success!"
                self.attemptLogin()
            }
        }
    }

    private func attemptLogin() {
        if let accessToken = currentAccessToken()?.tokenString {
            ref.authWithOAuthProvider("facebook", token: accessToken) {
                (error, authData) in
                if error != nil {
                    print("Login failed. \(error)")
                } else {
                    self.loginSuccess(authData)
                }
            }
        }
    }

    private func loginSuccess(authData: FAuthData) {
        print("Logged in as \(authData.providerData["displayName"]!)!")
        self.loginButton.titleLabel?.text = "Login success!"
        self.performSegueWithIdentifier("showMain", sender: nil)
    }

    private func currentAccessToken() -> FBSDKAccessToken? {
        return FBSDKAccessToken.currentAccessToken()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
