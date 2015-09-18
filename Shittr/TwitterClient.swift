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

enum TweetTimelineSource: String {
  case Home = "https://api.twitter.com/1.1/statuses/home_timeline.json"
  case Mentions = "https://api.twitter.com/1.1/statuses/mentions_timeline.json"
}

class TwitterClient: NSObject {
  static let sharedInstance = TwitterClient()
  private static let consumerKey = "idD00emRQLmntEpTqYveTJNP2"
  private static let consumerSecret = "6kt9jb6aAEAyayrQJ2fz748Q37mEdjXCkTnndV7QHojQTQOBzX"
  
  private let urlCache = NSURLCache(memoryCapacity: 0, diskCapacity: 1024 * 1024 * 2, diskPath: nil)
  private var client: OAuthSwiftClient!
  
  var oauthToken: String!
  var oauthTokenSecret: String!
  var user: User!
  
  override init() {
    super.init()
    
    let (creds, _) = Locksmith.loadDataForUserAccount("twitter")
    
    if let creds = creds, token = creds[OAuth.OAuthToken] as? String, secret = creds[OAuth.OAuthTokenSecret] as? String {
      self.createClient(token, secret: secret)
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
      
      self.createClient(credential.oauth_token, secret: credential.oauth_token_secret)
      
      completion(nil)
    }) { (error) -> Void in
      completion(error)
    }
  }
  
  func fetchUserInfo() {
    let params = Dictionary<String, AnyObject>()
    client.get("https://api.twitter.com/1.1/account/verify_credentials.json", parameters: params, success: { (data, response) -> Void in
      self.user = User(json: JSON(data: data))
    }) { (error) -> Void in
      NSLog(error.description)
    }
  }
  
  func fetchTweets(cached: Bool, source: TweetTimelineSource, completion: ([Tweet], NSError?) -> Void) {
    fetchTweetsFromUrl(cached, url: source.rawValue, completion: completion)
  }
  
  func fetchTweets(cached: Bool, source: TweetTimelineSource, afterTweet tweet: Tweet, completion: ([Tweet], NSError?) -> Void) {
    fetchTweetsFromUrl(cached, url: source.rawValue, params: [
      "max_id" : tweet.id
    ], completion: { (var tweets, error) in
      if tweets.count > 0 {
        tweets.removeAtIndex(0)
      }
      completion(tweets, error)
    })
  }
  
  func retweet(tweet: Tweet) {
    tweet.didRetweet = true
    let params = Dictionary<String, AnyObject>()
    client.post("https://api.twitter.com/1.1/statuses/retweet/\(tweet.id).json", parameters: params, success: nil) {(error) in
      NSLog("Unable to retweet: \(error.description)")
    }
  }
  
  func favorite(tweet: Tweet) {
    tweet.didFavorite = true
    let params = [
      "id": tweet.id
    ]
    client.post("https://api.twitter.com/1.1/favorites/create.json", parameters: params, success: nil) {(error) in
      NSLog("Unable to favorite: \(error.description)")
    }
  }
  
  func createTweet(text: String, reply: Tweet? = nil, completion: (Tweet?, NSError?) -> Void) {
    var params = [
      "status": text
    ]
    
    if let reply = reply {
      params["in_reply_to_status_id"] = reply.id
    }
    
    client.post("https://api.twitter.com/1.1/statuses/update.json", parameters: params, success: { (data, response) -> Void in
      completion(Tweet(json: JSON(data: data)), nil)
    }) { (error) -> Void in
      completion(nil, error)
    }
  }
  
  func logout() {
    Locksmith.deleteDataForUserAccount("twitter")
    client = nil
  }
  
  private func fetchTweetsFromUrl(cached: Bool, url: String, params: Dictionary<String, AnyObject>? = nil, completion: ([Tweet], NSError?) -> Void) {
    var params = params
    if params == nil {
      params = Dictionary<String, AnyObject>()
    }
    
    client.get(url, parameters: params!, success: { (data, response) -> Void in
      var tweets: [Tweet] = []
      let json = JSON(data: data).array!
      for entry in json {
        tweets.append(Tweet(json: entry))
      }
      completion(tweets, nil)
    }, failure: { (error) -> Void in
      if error.code == 401 {
        completion([], error) // TODO - Handle by reauthing?
      } else {
        completion([], error)
      }
    })
  }
  
  private func fetch(cached: Bool, url: String, completion: (NSData?, NSError?) -> Void) {
    // TODO
  }
  
  private func createClient(token: String, secret: String) {
    client = OAuthSwiftClient(
      consumerKey: TwitterClient.consumerKey,
      consumerSecret: TwitterClient.consumerSecret,
      accessToken: token,
      accessTokenSecret: secret
    )
    
    self.fetchUserInfo()
  }
}
