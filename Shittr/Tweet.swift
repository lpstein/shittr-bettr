//
//  Tweet.swift
//  Shittr
//
//  Created by Patrick Stein on 9/10/15.
//  Copyright (c) 2015 patrick. All rights reserved.
//

import UIKit
import SwiftyJSON

class Tweet: NSObject {
  private static let formatter = NSDateFormatter()
  private static let twitterDateFormat = "EEE MMM d HH:mm:ss Z y" // Example: Tue Aug 28 21:16:23 +0000 2012
                                                                  // See: http://waracle.net/iphone-nsdateformatter-date-formatting-table/
  let id: String
  let text: String
  let fullname: String
  let handle: String
  let avatarImage: NSURL
  let when: NSDate
  
  let didFavorite: Bool
  let didRetweet: Bool
  
  let retweetCount: Int
  let favoriteCount: Int
  
  init(json: JSON) {
    // Kind of a crappy static initialization, but it works and is thread
    // safe, soo...
    if Tweet.formatter.dateFormat != Tweet.twitterDateFormat {
      Tweet.formatter.dateFormat = Tweet.twitterDateFormat
    }
    
    id = json["id_str"].string!
    text = json["text"].string!
    fullname = json["user"]["name"].string!
    handle = "@" + json["user"]["screen_name"].string!
    when = Tweet.formatter.dateFromString(json["created_at"].string!)!
    
    didFavorite = json["favorited"].bool!
    didRetweet = json["retweeted"].bool!
    
    retweetCount = json["retweet_count"].int!
    favoriteCount = json["favorite_count"].int!
    
    var avatarUrl = json["user"]["profile_image_url_https"].string!
    avatarUrl = avatarUrl.stringByReplacingOccurrencesOfString("normal\\.png$", withString: "bigger.png", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
    avatarImage = NSURL(string: avatarUrl)!
  }
}
