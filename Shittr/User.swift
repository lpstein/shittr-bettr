//
//  User.swift
//  Shittr
//
//  Created by Patrick Stein on 9/18/15.
//  Copyright © 2015 patrick. All rights reserved.
//

import UIKit
import SwiftyJSON

class User {
  let name: String!
  let handle: String!
  let profileImage: NSURL!
  let coverImage: NSURL!
  let profileColor: UIColor!
  let textColor: UIColor!
  let linkColor: UIColor
  let useCoverImage: Bool
 
  init(json: JSON) {
    name = json["name"].string ?? ""
    handle = "@" + (json["screen_name"].string ?? "")
    profileImage = NSURL(string: json["profile_image_url_https"].string!.stringByReplacingOccurrencesOfString("normal\\.png$", withString: "reasonably_small.png", options: NSStringCompareOptions.RegularExpressionSearch, range: nil))!
    coverImage = NSURL(string: json["profile_background_image_url_https"].string!)!
    useCoverImage = json["profile_use_background_image"].bool ?? false
    profileColor = UIColor(hex: json["profile_background_color"].string!)
    textColor = UIColor(hex: json["profile_text_color"].string!)
    linkColor = UIColor(hex: json["profile_link_color"].string!)
  }
}