//
//  ReplaceEmbedSegue.swift
//  Shittr
//
//  Created by Patrick Stein on 9/17/15.
//  Copyright © 2015 patrick. All rights reserved.
//

import UIKit

class ReplaceEmbedSegue: UIStoryboardSegue {
  override func perform() {
    if let uberController = sourceViewController as? UberController {
      destinationViewController.view.frame = CGRectMake(0, 0, uberController.primaryView.frame.width, uberController.primaryView.frame.height)
      uberController.primaryViewController.willMoveToParentViewController(nil)
      uberController.addChildViewController(destinationViewController)
      
      uberController.primaryView.subviews[0].removeFromSuperview()
      uberController.primaryView.addSubview(destinationViewController.view)
      
      uberController.primaryViewController.removeFromParentViewController()
      destinationViewController.didMoveToParentViewController(uberController)
      uberController.primaryViewController = destinationViewController
      
      uberController.closeDrawer()
    }
  }
}
