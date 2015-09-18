//
//  HomeController.swift
//  Shittr
//
//  Created by Patrick Stein on 9/18/15.
//  Copyright © 2015 patrick. All rights reserved.
//

import UIKit

class HomeController: UINavigationController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let root = childViewControllers[0] as? TweetListController {
      root.source = TweetTimelineSource.Home
      root.navigationItem.title = "Home"
    }
  }
}
