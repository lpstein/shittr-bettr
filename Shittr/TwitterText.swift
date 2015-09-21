//
//  TwitterText.swift
//  Shittr
//
//  Created by Patrick Stein on 9/21/15.
//  Copyright © 2015 patrick. All rights reserved.
//

import UIKit

class TwitterText {
  private static let hashtagRegex = try! NSRegularExpression(pattern: "#\\w+", options: [])
  private static let hashtagColor = UIColor(red: 102 / 255.0, green: 117 / 255.0, blue: 127 / 255.0, alpha: 1.0)
  private static let mentionRegex = try! NSRegularExpression(pattern: "@\\w+", options: [])
  private static let mentionColor = UIColor(red: 85 / 255.0, green: 172 / 255.0, blue: 238 / 255.0, alpha: 1.0)
  
  class func highlightTweet(text: String) -> NSAttributedString {
    let text = NSMutableAttributedString(string: text)
    TwitterText.applyAttributes(text, regex: TwitterText.hashtagRegex, attrs: [
      NSForegroundColorAttributeName : TwitterText.hashtagColor
    ])
    TwitterText.applyAttributes(text, regex: TwitterText.mentionRegex, attrs: [
      NSForegroundColorAttributeName : TwitterText.mentionColor
    ])
    
    return text
  }
  
  private class func applyAttributes(text: NSMutableAttributedString, regex: NSRegularExpression, attrs: [String : AnyObject]?) {
    let matches = regex.matchesInString(text.string, options: [], range: NSMakeRange(0, text.length))
    for match in matches {
      text.setAttributes(attrs, range: match.range)
    }
  }
}
