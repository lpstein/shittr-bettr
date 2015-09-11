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
    return tweets.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
}
