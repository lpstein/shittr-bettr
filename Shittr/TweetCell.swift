//
//  TweetCell.swift
//  Shittr
//
//  Created by Patrick Stein on 9/10/15.
//  Copyright (c) 2015 patrick. All rights reserved.
//

import UIKit
import DateTools
import AFNetworking

protocol TweetListProtocol {
  func replyTo(tweet: Tweet)
  func goToProfile(user: User)
}

class TweetCell: UITableViewCell {
  private static let hashtagRegex = try! NSRegularExpression(pattern: "#\\w+", options: [])
  private static let hashtagColor = UIColor(red: 102 / 255.0, green: 117 / 255.0, blue: 127 / 255.0, alpha: 1.0)
  private static let mentionRegex = try! NSRegularExpression(pattern: "@\\w+", options: [])
  private static let mentionColor = UIColor(red: 85 / 255.0, green: 172 / 255.0, blue: 238 / 255.0, alpha: 1.0)
  
  @IBOutlet weak var whenLabel: UILabel!
  @IBOutlet weak var handleLabel: UILabel!
  @IBOutlet weak var fullnameLabel: UILabel!
  @IBOutlet weak var avatarImage: UIImageView!
  @IBOutlet weak var tweetTextLabel: UILabel!
  
  @IBOutlet weak var replyImage: UIImageView!
  @IBOutlet weak var retweetImage: UIImageView!
  @IBOutlet weak var favoriteImage: UIImageView!
  
  var delegate: TweetListProtocol?
  
  var tweet: Tweet? {
    didSet {
      if let tweet = tweet {
        // Basic stuff
        handleLabel.text = tweet.user.handle
        fullnameLabel.text = tweet.user.name
        whenLabel.text = tweet.when.shortTimeAgoSinceNow()
        avatarImage.setImageWithURL(tweet.user.profileImage)
      
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
        
        // Get funky with the tweet text itself
        let text = NSMutableAttributedString(string: tweet.text)
        applyAttributes(text, regex: TweetCell.hashtagRegex, attrs: [
          NSForegroundColorAttributeName : TweetCell.hashtagColor
        ])
        applyAttributes(text, regex: TweetCell.mentionRegex, attrs: [
          NSForegroundColorAttributeName : TweetCell.mentionColor
        ])
        
        tweetTextLabel.attributedText = text
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    avatarImage.layer.cornerRadius = 4.0
    avatarImage.clipsToBounds = true
  }
  
  @IBAction func profileImageTouched(sender: AnyObject) {
    if let delegate = self.delegate, tweet = tweet {
      delegate.goToProfile(tweet.user)
    }
  }
  
  @IBAction func replyTouched(sender: AnyObject) {
    if let delegate = self.delegate, tweet = tweet {
      delegate.replyTo(tweet)
    }
  }
  
  @IBAction func retweetTouched(sender: AnyObject) {
    if let tweet = tweet {
      TwitterClient.sharedInstance.retweet(tweet)
      retweetImage.image = UIImage(named: "RetweetOn")
    }
  }
  
  @IBAction func favoriteTouched(sender: AnyObject) {
    if let tweet = tweet {
      TwitterClient.sharedInstance.favorite(tweet)
      favoriteImage.image = UIImage(named: "FavoriteOn")
    }
  }
  
  private func applyAttributes(text: NSMutableAttributedString, regex: NSRegularExpression, attrs: [String : AnyObject]?) {
    let matches = regex.matchesInString(text.string, options: [], range: NSMakeRange(0, text.length)) 
    for match in matches {
      text.setAttributes(attrs, range: match.range)
    }
  }
}
