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

struct OAuth {
  static let OAuthToken = "oauth_token"
  static let OAuthTokenSecret = "oauth_token_secret"
}

class TwitterClient: NSObject {
  static let sharedInstance = TwitterClient()
  
  var oauthToken: String!
  var oauthTokenSecret: String!
  
  override init() {
    let (creds, error) = Locksmith.loadDataForUserAccount("twitter")
    
    if let creds = creds, token = creds[OAuth.OAuthToken] as? String, secret = creds[OAuth.OAuthTokenSecret] as? String {
      oauthToken = token
      oauthTokenSecret = secret
    }
  }
  
  var hasCredentials: Bool {
    get {
      return oauthToken != nil && oauthTokenSecret != nil
    }
  }
  
  func loginWithCompletion(completion: (NSError?) -> ()) {
    let oauth = OAuth1Swift(
      consumerKey: "idD00emRQLmntEpTqYveTJNP2",
      consumerSecret: "6kt9jb6aAEAyayrQJ2fz748Q37mEdjXCkTnndV7QHojQTQOBzX",
      requestTokenUrl: "https://api.twitter.com/oauth/request_token",
      authorizeUrl: "https://api.twitter.com/oauth/authorize",
      accessTokenUrl: "https://api.twitter.com/oauth/access_token"
    )
    oauth.authorizeWithCallbackURL(NSURL(string: "oauth-swift://oauth-callback/twitter")!, success: { (credential, response) -> Void in
      Locksmith.updateData([
        OAuth.OAuthToken: credential.oauth_token,
        OAuth.OAuthTokenSecret: credential.oauth_token_secret
      ], forUserAccount: "twitter")
      
      self.oauthToken = credential.oauth_token
      self.oauthTokenSecret = credential.oauth_token_secret
      
      completion(nil)
    }) { (error) -> Void in
      completion(error)
    }
  }
}
