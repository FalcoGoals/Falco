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


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginTapped(sender: AnyObject) {
        FBSDKLoginManager().logInWithReadPermissions(["email"], fromViewController: self) {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

}
