//
//  SettingsController.swift
//  Shittr
//
//  Created by Patrick Stein on 9/21/15.
//  Copyright © 2015 patrick. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {
  @IBOutlet weak var autoloadSwitch: UISwitch!
  @IBOutlet weak var coverEffectsSwitch: UISwitch!

  var map = Dictionary<UISwitch, String>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    map[autoloadSwitch] = "disable_autoload"
    map[coverEffectsSwitch] = "disable_cover_effects"
    
    for (sw, key) in map {
      sw.on = Settings.global[key]
    }
  }
  
  @IBAction func optionToggled(sender: UISwitch) {
    update(map[sender]!, val: sender.on)
  }
  
  private func update(name: String, val: Bool) {
    Settings.global[name] = val
  }
}
