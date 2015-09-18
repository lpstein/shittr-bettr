//
//  DrawController.swift
//  Shittr
//
//  Created by Patrick Stein on 9/17/15.
//  Copyright © 2015 patrick. All rights reserved.
//

import UIKit

class DrawerController: UITableViewController {
  private static let Sections = [
    "Shittr": [
      "Home": "com.shazam.segue.embed.home",
      "Mentions": "com.shazam.segue.embed.mentions"
    ],
    "Account": [
      "Profile": "com.shazam.segue.embed.profile",
      "Settings": "com.shazam.segue.embed.settings",
      "Logout": "logout"
    ]
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length, 0.0, 0.0, 0.0);
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.backgroundColor = UIColor.blackColor()
    tableView.reloadData()
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return DrawerController.Sections.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let keys = Array(DrawerController.Sections.keys)
    return DrawerController.Sections[keys[section]]!.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("com.shazam.cell.nav", forIndexPath: indexPath) as! LinkCell
    
    let (name, _) = infoForCell(indexPath)
    cell.name = name
    
    return cell
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return Array(DrawerController.Sections.keys)[section]
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let (_, segue) = infoForCell(indexPath)
    parentViewController?.performSegueWithIdentifier(segue, sender: self)
  }
  
  private func infoForCell(indexPath: NSIndexPath) -> (String, String) {
    let sections = DrawerController.Sections
    let section = sections[Array(sections.keys)[indexPath.section]]!
    
    let name = Array(section.keys)[indexPath.row]
    let segue = section[name]!
    
    return (name, segue)
  }
}
