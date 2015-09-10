//
//  LoginController.swift
//  Shittr
//
//  Created by Patrick Stein on 9/10/15.
//  Copyright (c) 2015 patrick. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if TwitterClient.sharedInstance.hasCredentials {
       self.performSegueWithIdentifier("com.shazam.segue.launch.static", sender: self)
    }
  }
  
  @IBAction func launchAuth(sender: AnyObject) {
    TwitterClient.sharedInstance.loginWithCompletion { (error) -> () in
      if let error = error {
        NSLog("Error logging in: \(error.description)")
        UIAlertView(title: "Login Error", message: "Something went wrong while logging in, please try again", delegate: nil, cancelButtonTitle: "Well, ok").show()
      } else {
        self.performSegueWithIdentifier("com.shazam.segue.launch", sender: self)
      }
    }
  }
}
