//
//  TweetCell.swift
//  Shittr
//
//  Created by Patrick Stein on 9/10/15.
//  Copyright (c) 2015 patrick. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
  @IBOutlet weak var tweetTextLabel: UILabel!
  
  var tweet: Tweet? {
    didSet {
      if let tweet = tweet {
        tweetTextLabel.text = tweet.text
      }
    }
  }
}
