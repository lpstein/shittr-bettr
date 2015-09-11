//
//  TwitterClient.swift
//  Shittr
//
//  Created by Patrick Stein on 9/10/15.
//  Copyright (c) 2015 patrick. All rights reserved.
//

import UIKit
import OAuthSwift
import Locksmith
import SwiftyJSON

struct OAuth {
  static let OAuthToken = "oauth_token"
  static let OAuthTokenSecret = "oauth_token_secret"
}

class TwitterClient: NSObject {
  static let sharedInstance = TwitterClient()
  static let consumerKey = "idD00emRQLmntEpTqYveTJNP2"
  static let consumerSecret = "6kt9jb6aAEAyayrQJ2fz748Q37mEdjXCkTnndV7QHojQTQOBzX"
  
  let urlCache = NSURLCache(memoryCapacity: 0, diskCapacity: 1024 * 1024 * 2, diskPath: nil)
  var client: OAuthSwiftClient!
  
  var oauthToken: String!
  var oauthTokenSecret: String!
  
  override init() {
    let (creds, error) = Locksmith.loadDataForUserAccount("twitter")
    
    if let creds = creds, token = creds[OAuth.OAuthToken] as? String, secret = creds[OAuth.OAuthTokenSecret] as? String {
      self.client = OAuthSwiftClient(
        consumerKey: TwitterClient.consumerKey,
        consumerSecret: TwitterClient.consumerSecret,
        accessToken: token,
        accessTokenSecret: secret
      )
    }
  }
  
  var hasCredentials: Bool {
    get {
      return client != nil
    }
  }
  
  func loginWithCompletion(completion: (NSError?) -> ()) {
    let oauth = OAuth1Swift(
      consumerKey: TwitterClient.consumerKey,
      consumerSecret: TwitterClient.consumerSecret,
      requestTokenUrl: "https://api.twitter.com/oauth/request_token",
      authorizeUrl: "https://api.twitter.com/oauth/authorize",
      accessTokenUrl: "https://api.twitter.com/oauth/access_token"
    )
    oauth.authorizeWithCallbackURL(NSURL(string: "oauth-swift://oauth-callback/twitter")!, success: { (credential, response) -> Void in
      Locksmith.updateData([
        OAuth.OAuthToken: credential.oauth_token,
        OAuth.OAuthTokenSecret: credential.oauth_token_secret
      ], forUserAccount: "twitter")
      
      self.client = OAuthSwiftClient(
        consumerKey: TwitterClient.consumerKey,
        consumerSecret: TwitterClient.consumerSecret,
        accessToken: credential.oauth_token,
        accessTokenSecret: credential.oauth_token_secret
      )
      
      completion(nil)
    }) { (error) -> Void in
      completion(error)
    }
  }
  
  func fetchTweets(cached: Bool, completion: ([Tweet], NSError?) -> Void) {
    let params = Dictionary<String, AnyObject>()
    client.get("https://api.twitter.com/1.1/statuses/home_timeline.json", parameters: params, success: { (data, response) -> Void in
      var tweets: [Tweet] = []
      let json = JSON(data: data).array!
      for entry in json {
        tweets.append(Tweet(json: entry))
      }
      completion(tweets, nil)
    }) { (error) -> Void in
      completion([], error)
    }
  }
}
