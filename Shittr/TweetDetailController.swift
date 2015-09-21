//
//  TweetDetailController.swift
//  Shittr
//
//  Created by Patrick Stein on 9/11/15.
//  Copyright (c) 2015 patrick. All rights reserved.
//

import UIKit

class TweetDetailController: UIViewController {
  private static let formatter = NSDateFormatter()
  private static let dateFormat = "MMM d y, h:mm a"
  
  
  @IBOutlet weak var favoriteCountLabel: UILabel!
  @IBOutlet weak var retweetCountLabel: UILabel!
  @IBOutlet weak var whenLabel: UILabel!
  @IBOutlet weak var handleLabel: UILabel!
  @IBOutlet weak var fullnameLabel: UILabel!
  @IBOutlet weak var avatarImage: UIImageView!
  @IBOutlet weak var tweetTextLabel: UILabel!
  
  @IBOutlet weak var replyImage: UIImageView!
  @IBOutlet weak var retweetImage: UIImageView!
  @IBOutlet weak var favoriteImage: UIImageView!
  
  var tweet: Tweet?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if TweetDetailController.formatter.dateFormat != TweetDetailController.dateFormat {
      TweetDetailController.formatter.dateFormat = TweetDetailController.dateFormat
      TweetDetailController.formatter.timeZone = NSTimeZone.systemTimeZone()
    }
    
    avatarImage.layer.cornerRadius = 4.0
    avatarImage.clipsToBounds = true
    
    if let tweet = tweet {
      navigationItem.title = "Tweet by \(tweet.user.name)"
      
      // Basic stuff
      handleLabel.text = tweet.user.handle
      fullnameLabel.text = tweet.user.name
      whenLabel.text = TweetDetailController.formatter.stringFromDate(tweet.when)
      avatarImage.setImageWithURL(tweet.user.profileImage)
      favoriteCountLabel.text = "\(tweet.favoriteCount)"
      retweetCountLabel.text = "\(tweet.retweetCount)"
      tweetTextLabel.attributedText = TwitterText.highlightTweet(tweet.text)
      
      // Use the "On" version of images if this user has performed
      // actions on the tweet in question
      if tweet.didRetweet {
        retweetImage.image = UIImage(named: "RetweetOn")
      } else {
        retweetImage.image = UIImage(named: "Retweet")
      }
      if tweet.didFavorite {
        favoriteImage.image = UIImage(named: "FavoriteOn")
      } else {
        favoriteImage.image = UIImage(named: "Favorite")
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let controller = segue.destinationViewController as? CreateTweetController {
      controller.replyTo = tweet
      if let stack = navigationController?.viewControllers {
        controller.delegate = stack[stack.count - 2] as? AddTweetProtocol
      }
    }
    
    if let vc = segue.destinationViewController as? ProfileController {
      vc.user = tweet!.user
    }
  }
  
  @IBAction func favoriteTouched(sender: AnyObject) {
    favoriteImage.image = UIImage(named: "FavoriteOn")
    if let tweet = tweet {
      TwitterClient.sharedInstance.favorite(tweet)
    }
  }
  
  @IBAction func retweetTouched(sender: AnyObject) {
    retweetImage.image = UIImage(named: "RetweetOn")
    if let tweet = tweet {
      TwitterClient.sharedInstance.retweet(tweet)
    }
  }
}
