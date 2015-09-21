//
//  TweetListController.swift
//  Shittr
//
//  Created by Patrick Stein on 9/10/15.
//  Copyright (c) 2015 patrick. All rights reserved.
//

import UIKit
import AFNetworking

protocol AddTweetProtocol {
  func addTweet(tweet: Tweet)
}

class TweetListController: UITableViewController, AddTweetProtocol, TweetListProtocol {
  @IBOutlet weak var profileHeaderView: UIView!
  @IBOutlet weak var blurEffect: UIVisualEffectView!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var coverImage: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var tweetCount: UILabel!
  @IBOutlet weak var followingCount: UILabel!
  @IBOutlet weak var followersCount: UILabel!
  
  
  var source = TweetTimelineSource.Home
  var user: User?
  
  var tweets: [Tweet] = []
  var destinationTweet: Tweet? = nil
  var fetchingMoreTweets = false
  
  var replyingTo: Tweet?
  var profileTo: User?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let user = user {
      navigationItem.title = user.handle
      nameLabel.text = user.name
      
      profileImage.setImageWithURL(user.profileImage)
      profileImage.clipsToBounds = true
      profileImage.layer.cornerRadius = 4

      tweetCount.text = String(user.tweetCount)
      followingCount.text = String(user.followingCount)
      followersCount.text = String(user.followersCount)
      
      coverImage.backgroundColor = user.linkColor
      if user.useCoverImage {
        coverImage.alpha = 0
        coverImage.setImageWithURL(user.coverImage)
        UIView.animateWithDuration(0.6, animations: { () -> Void in
          self.coverImage.alpha = 1
        })
      }
    } else {
      tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 1))
    
      refreshControl = UIRefreshControl()
      refreshControl?.addTarget(self, action: "userDidRefresh:", forControlEvents: UIControlEvents.ValueChanged)
      tableView.insertSubview(refreshControl!, atIndex: 0)
    }
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 80
    
    reload()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let _ = user {
      blurEffect.alpha = 0.0
    }
    
    tableView.reloadData()
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    if let blurEffect = blurEffect {
      let offset = scrollView.contentOffset.y
      let navHeight = navigationController?.navigationBar.frame.size.height ?? 0
      let y = offset + navHeight
      
      blurEffect.alpha = max(0, min(1, y * 3 / tableView.tableHeaderView!.bounds.height))
      NSLog("Alpha: \(blurEffect.alpha)")
    }
  }
  
  func userDidRefresh(sender: AnyObject?) {
    reload(false)
  }
  
  func addTweet(tweet: Tweet) {
    tweets.insert(tweet, atIndex: 0)
    tableView.setContentOffset(CGPointMake(0, -tableView.contentInset.top), animated: true)
    tableView.reloadData()
  }
  
  func replyTo(tweet: Tweet) {
    replyingTo = tweet
    performSegueWithIdentifier("com.shazam.segue.create", sender: self)
  }
  
  func goToProfile(user: User) {
    profileTo = user
    // performSegueWithIdentifier("com.shazam.segue.profile", sender: self)
  }
  
  private func reload(cached: Bool = true) {
    let completion: ([Tweet], NSError?) -> Void = { (tweets, error) -> Void in
      // Clear refreshing state if it's active
      if let refresh = self.refreshControl {
        if refresh.refreshing {
          refresh.endRefreshing()
        }
      }
      
      if let error = error {
        let alert = UIAlertView(title: "Error", message: error.description, delegate: nil, cancelButtonTitle: "Bummer")
        alert.show()
      }
      
      // Trigger a data update
      self.tweets = tweets
      self.tableView.reloadData()
    }
    
    if source == .User {
      TwitterClient.sharedInstance.fetchTweets(false, source: source, forUser: user!, completion: completion)
    } else {
      TwitterClient.sharedInstance.fetchTweets(false, source: source, completion: completion)
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count + 1 // Extra one for a loading spinner cell
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == tweets.count {
      if tweets.count != 0 {
        getMoreTweets()
      }
      let cell = tableView.dequeueReusableCellWithIdentifier("com.shazam.cell.spinner", forIndexPath: indexPath) 
      let spinner = cell.contentView.subviews[0] as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier("com.shazam.cell.tweet", forIndexPath: indexPath) as! TweetCell
    cell.tweet = tweets[indexPath.row]
    cell.delegate = self
    return cell
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if tableView.respondsToSelector("setSeparatorInset:") {
      tableView.separatorInset = UIEdgeInsetsZero
    }
    if tableView.respondsToSelector("setLayoutMargins:") {
      tableView.layoutMargins = UIEdgeInsetsZero
    }
    if cell.respondsToSelector("setLayoutMargins:") {
      cell.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row >= tweets.count {
      return
    }
    
    destinationTweet = tweets[indexPath.row]
    performSegueWithIdentifier("com.shazam.segue.tweet", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let controller = segue.destinationViewController as? TweetDetailController {
      controller.tweet = destinationTweet
    }
    if let controller = segue.destinationViewController as? CreateTweetController {
      controller.delegate = self
      controller.replyTo = self.replyingTo
      self.replyingTo = nil
    }
    if let vc = segue.destinationViewController as? TweetListController, profileTo = profileTo {
      vc.user = profileTo
      vc.source = .User
    }
  }
  
  private func getMoreTweets() {
    if !fetchingMoreTweets && source != .User {
      
      fetchingMoreTweets = true
      TwitterClient.sharedInstance.fetchTweets(true, source: source, afterTweet: self.tweets.last!, completion: { (moreTweets, error) -> Void in
        
        self.fetchingMoreTweets = false
        
        // Silently fail if we errored out
        if let error = error {
          NSLog(error.description)
          return
        }
        
        self.tweets += moreTweets
        self.tableView.reloadData()
      })
    }
  }
}
