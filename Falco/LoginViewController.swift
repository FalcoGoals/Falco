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

protocol LoginDelegate {
    func didReceiveToken()
}

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    var delegate: LoginDelegate!

    @IBOutlet var loginButton: FBSDKLoginButton!

    override func viewDidLoad() {
        loginButton.readPermissions = ["email", "user_friends"]
        loginButton.delegate = self
    }

    // MARK: FBSDKLoginButtonDelegate

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            print("Facebook login failed. Error \(error)")
        } else if result.isCancelled {
            print("Facebook login was cancelled.")
        } else {
            delegate.didReceiveToken()
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }

}
