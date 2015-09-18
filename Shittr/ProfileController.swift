//
//  ProfileController.swift
//  Shittr
//
//  Created by Patrick Stein on 9/18/15.
//  Copyright © 2015 patrick. All rights reserved.
//

import UIKit
import AFNetworking

class ProfileController: UIViewController {
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var coverImage: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  
  var user: User?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let user = user {
      navigationItem.title = user.handle
      nameLabel.text = user.name
      
      profileImage.setImageWithURL(user.profileImage)
      profileImage.clipsToBounds = true
      profileImage.layer.cornerRadius = 4
      
      coverImage.backgroundColor = user.linkColor
      if user.useCoverImage {
        coverImage.setImageWithURL(user.coverImage)
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    coverImage.alpha = 0.0
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    UIView.animateKeyframesWithDuration(0.6, delay: 0, options: [], animations: { () -> Void in
      self.coverImage.alpha = 1.0
    }) { (_) -> Void in
        
    }
  }
}