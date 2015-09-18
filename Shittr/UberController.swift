//
//  UberController.swift
//  Shittr
//
//  Created by Patrick Stein on 9/17/15.
//  Copyright © 2015 patrick. All rights reserved.
//

import UIKit

class UberController : UIViewController {
  @IBOutlet weak var primaryView: UIView!
  weak var primaryViewController: UIViewController!
  
  var drawerOpen = false
  var startLocation: CGPoint?
  var startMs: Double = 0
  var dx: CGFloat = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Give the primary view a drop shadow
    let layer = primaryView.layer
    layer.masksToBounds = false
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOffset = CGSizeMake(-5.0, 0.0)
    layer.shadowOpacity = 0.5
    layer.shadowPath = UIBezierPath(rect: primaryView.bounds).CGPath
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Bootstrap the primary VC
    if segue.identifier == "bootstrap" && primaryViewController == nil {
      primaryViewController = segue.destinationViewController
    }

    // For any nav controller added, create a hamburger toggle button for the
    // root controller.
    if let vc = segue.destinationViewController as? UINavigationController {
      vc.childViewControllers[0].navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "toggleDrawer")
    }
  }
  
  override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
    // Blarghhhhh
    if identifier == "logout" {
      TwitterClient.sharedInstance.logout()
      dismissViewControllerAnimated(true, completion: nil)
    } else {
      super.performSegueWithIdentifier(identifier, sender: sender)
    }
  }
  
  @IBAction func swiping(sender: UIPanGestureRecognizer) {
    if sender.state == .Began {
      startLocation = sender.locationOfTouch(0, inView: nil)
      startMs = NSDate().timeIntervalSince1970
    } else if sender.state == .Ended {
      startLocation = nil
      let dt = CGFloat(NSDate().timeIntervalSince1970 - startMs)
      
      // Consider the drawer opened based on distance and swipe velocity
      let width = primaryView.frame.width
      if dx > width / 2 || (dx > width / 8 && dx / dt > 300) {
        openDrawer()
      } else {
        closeDrawer()
      }

    } else {
      if let startLocation = startLocation {
        dx = sender.locationOfTouch(0, inView: nil).x - startLocation.x
        dx = min(dx, primaryView.frame.width)
        dx = max(dx, 0)
        primaryView.transform = CGAffineTransformMakeTranslation(dx, 0)
      }
    }
  }
  
  func toggleDrawer() {
    if drawerOpen {
      closeDrawer()
    } else {
      openDrawer()
    }
  }
  
  func openDrawer() {
    drawerOpen = true
    drawToTarget(primaryView.frame.width * 0.8)
  }
  
  func closeDrawer() {
    drawerOpen = false
    drawToTarget(0)
  }
  
  private func drawToTarget(target: CGFloat) {
    // When animating, use a fixed *velocity* rather than a fixed time.
    // Keeps things from getting wonky when we're going a small distance.
    //
    // TODO - Modifying spring force to match?
    let current = primaryView.transform.tx
    let velocity: CGFloat = 600 // px per second
    let time = abs(target - current) / velocity
    
    UIView.animateWithDuration(Double(time), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: (500 - time) / 500, options: [
      UIViewAnimationOptions.CurveEaseIn
    ], animations: { () -> Void in
      self.primaryView.transform = CGAffineTransformMakeTranslation(target, 0)
    }, completion: nil)
    
    NSLog("Animation duration: \(Int(time * 1000))")
  }
}
