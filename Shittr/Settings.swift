//
//  Settings.swift
//  Shittr
//
//  Created by Patrick Stein on 9/21/15.
//  Copyright © 2015 patrick. All rights reserved.
//

import UIKit

class Settings {
  private static var state = NSUserDefaults.standardUserDefaults()
  public static let global = Settings()
  
  subscript(name: String) -> Bool {
    get {
      return Settings.state.boolForKey(name)
    }
    set(val) {
      Settings.state.setBool(val, forKey: name)
    }
  }
}
