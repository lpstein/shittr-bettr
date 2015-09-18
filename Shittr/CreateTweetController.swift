//
//  CreateTweetController.swift
//  Shittr
//
//  Created by Patrick Stein on 9/14/15.
//  Copyright (c) 2015 patrick. All rights reserved.
//

import UIKit

class CreateTweetController: UIViewController, UITextViewDelegate {
  @IBOutlet weak var handleLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var tweetText: UITextView!
  @IBOutlet weak var charCounter: UILabel!
  
  var delegate: AddTweetProtocol?
  var replyTo: Tweet?
  
  // Used to adjust to keyboard size
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    profileImage.layer.cornerRadius = 4.0
    profileImage.clipsToBounds = true
    
    let user = TwitterClient.sharedInstance.user
    nameLabel.text = user.name
    handleLabel.text = user.handle
    profileImage.setImageWithURL(user.profileImage)
    tweetText.becomeFirstResponder()
    tweetText.delegate = self
    
    if let replyTo = replyTo {
      tweetText.text = replyTo.user.handle + " "
    }
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChange:", name: nil, object: nil)
  }
  
  func keyboardChange(notification: NSNotification) {
    if let raw = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardFrame = raw.CGRectValue()
      bottomConstraint.constant = 8 + keyboardFrame.height
    }
  }
  
  func textViewDidChange(tweetText: UITextView) {
    let chars = tweetText.text.characters.count
    
    charCounter.text = "\(140 - chars)"
    if chars > 140 {
      charCounter.textColor = UIColor.redColor()
    } else {
      charCounter.textColor = UIColor.lightGrayColor()
    }
  }

  @IBAction func createTweet(sender: AnyObject) {
    if tweetText.text.characters.count > 140 {
      let alert = UIAlertView(title: "Whoa now", message: "Way too many letters in that tweet, dude.  Make it shorter.", delegate: nil, cancelButtonTitle: "Ugh, fine")
      alert.show()
      return
    }
    
    TwitterClient.sharedInstance.createTweet(tweetText.text, reply: replyTo) { (tweet, error) -> Void in
      if let error = error {
        let alert = UIAlertView(title: "Failure", message: error.description, delegate: nil, cancelButtonTitle: "Well, shit")
        alert.show()
        return
      }
      
      if let delegate = self.delegate {
        delegate.addTweet(tweet!)
      }
      self.navigationController?.popViewControllerAnimated(true)
    }
  }
}
