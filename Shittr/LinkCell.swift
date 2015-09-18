//
//  LinkCell.swift
//  Shittr
//
//  Created by Patrick Stein on 9/17/15.
//  Copyright © 2015 patrick. All rights reserved.
//

import UIKit

class LinkCell: UITableViewCell {
  @IBOutlet weak var contentLabel: UILabel!
  
  var name: String! {
    didSet {
      contentLabel.text = name
    }
  }
}