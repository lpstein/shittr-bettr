//
//  ColorExtensions.swift
//  Shittr
//
//  Created by Patrick Stein on 9/18/15.
//  Copyright © 2015 patrick. All rights reserved.
//

import UIKit

extension UIColor {
  convenience init(hex: String) {
    let scanner = NSScanner(string: hex)
    
    // Skip any leading #
    if hex.characters.count == 7 {
      scanner.scanLocation = 1
    }
    
    var val: UInt32 = 0
    scanner.scanHexInt(&val)
    
    let red = CGFloat((val & 0xFF0000) >> 16)
    let green = CGFloat((val & 0x00FF00) >> 8)
    let blue = CGFloat(val & 0x0000FF)
    
    self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
  }
}
