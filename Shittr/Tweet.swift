//
//  Tweet.swift
//  Shittr
//
//  Created by Patrick Stein on 9/10/15.
//  Copyright (c) 2015 patrick. All rights reserved.
//

import UIKit
import SwiftyJSON

class Tweet: NSObject {
  let text: String!
  
  init(json: JSON) {
    text = json["text"].string!
  }
}
