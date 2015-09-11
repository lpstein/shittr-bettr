//
//  TweetListController.swift
//  Shittr
//
//  Created by Patrick Stein on 9/10/15.
//  Copyright (c) 2015 patrick. All rights reserved.
//

import UIKit

class TweetListController: UITableViewController {
  var tweets: [Tweet] = []
  var destinationTweet: Tweet? = nil
  var fetchingMoreTweets = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: "userDidRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    tableView.insertSubview(refreshControl!, atIndex: 0)
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 80
//    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    
    reload()
  }
  
  func userDidRefresh(sender: AnyObject?) {
    reload(cached: false)
  }
  
  private func reload(cached: Bool = true) {
    TwitterClient.sharedInstance.fetchTweets(cached, completion: { (tweets, error) -> Void in
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
    })
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count + 1 // Extra one for a loading spinner cell
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == tweets.count {
      if tweets.count != 0 {
        getMoreTweets()
      }
      let cell = tableView.dequeueReusableCellWithIdentifier("com.shazam.cell.spinner", forIndexPath: indexPath) as! UITableViewCell
      let spinner = cell.contentView.subviews[0] as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    }
    
    var cell = tableView.dequeueReusableCellWithIdentifier("com.shazam.cell.tweet", forIndexPath: indexPath) as! TweetCell
    cell.tweet = tweets[indexPath.row]
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
  }
  
  private func getMoreTweets() {
    if !fetchingMoreTweets {
      
      fetchingMoreTweets = true
      TwitterClient.sharedInstance.fetchTweets(true, afterTweet: self.tweets.last!, completion: { (moreTweets, error) -> Void in
        
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
