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
  
  // Used to adjust to keyboard size
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    profileImage.layer.cornerRadius = 4.0
    profileImage.clipsToBounds = true
    
    let info = TwitterClient.sharedInstance.userInfo
    nameLabel.text = info?["name"].string ?? ""
    handleLabel.text = "@" + (info?["screen_name"].string ?? "")
    if let urlStr = info?["profile_image_url_https"].string, url = NSURL(string: urlStr) {
      profileImage.setImageWithURL(url)
    }
    tweetText.becomeFirstResponder()
    tweetText.delegate = self
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChange:", name: nil, object: nil)
  }
  
  func keyboardChange(notification: NSNotification) {
    if let raw = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardFrame = raw.CGRectValue()
      bottomConstraint.constant = 8 + keyboardFrame.height
    }
  }
  
  func textViewDidChange(tweetText: UITextView) {
    let chars = count(tweetText.text)
    
    charCounter.text = "\(140 - chars)"
    if chars > 140 {
      charCounter.textColor = UIColor.redColor()
    } else {
      charCounter.textColor = UIColor.lightGrayColor()
    }
  }

  @IBAction func createTweet(sender: AnyObject) {
    if count(tweetText.text) > 140 {
      let alert = UIAlertView(title: "Whoa now", message: "Way too many letters in that tweet, dude.  Make it shorter.", delegate: nil, cancelButtonTitle: "Ugh, fine")
      alert.show()
      return
    }
    
    TwitterClient.sharedInstance.createTweet(tweetText.text, reply: nil) { (tweet, error) -> Void in
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
