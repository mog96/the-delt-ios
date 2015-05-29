//
//  MenuViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var hamburgerViewController: HamburgerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell") as! UITableViewCell
            return cell
        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier("ChatCell") as! UITableViewCell
            return cell
        case 2:
            var cell = tableView.dequeueReusableCellWithIdentifier("ReelCell")as! UITableViewCell
            return cell
        case 3:
            var cell = tableView.dequeueReusableCellWithIdentifier("CalendarCell")as! UITableViewCell
            return cell
        case 4:
            var cell = tableView.dequeueReusableCellWithIdentifier("MembersCell") as! UITableViewCell
            return cell
        default:
            var cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as! UITableViewCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
   
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print(indexPath.row)
        switch indexPath.row {
        case 0:
            var profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
            var profileController = profileStoryboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! UIViewController
            hamburgerViewController?.contentViewController = profileController
            
        case 1: // CHAT
            var chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
            var chatNavigationController = chatStoryboard.instantiateViewControllerWithIdentifier("ChatNavigationController") as! UINavigationController
            hamburgerViewController?.contentViewController = chatNavigationController
            
        case 2: // REEL
            var reelStoryboard = UIStoryboard(name: "Reel", bundle: nil)
            var reelNavigationController = reelStoryboard.instantiateViewControllerWithIdentifier("Nav") as! UINavigationController
            hamburgerViewController?.contentViewController = reelNavigationController
            
        case 3: // CALENDAR
            var eventsStoryboard = UIStoryboard(name: "Calendar", bundle: nil)
            var eventsNavigationController = eventsStoryboard.instantiateViewControllerWithIdentifier("Nav") as! UINavigationController
            hamburgerViewController?.contentViewController = eventsNavigationController
            
        case 4: // MEMBERS
            var reelStoryboard = UIStoryboard(name: "Members", bundle: nil)
            var reelNavigationController = reelStoryboard.instantiateViewControllerWithIdentifier("Members") as! UINavigationController
            hamburgerViewController?.contentViewController = reelNavigationController
            
        default: // SETTINGS
            var settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
            var settingsNavigationController = settingsStoryboard.instantiateViewControllerWithIdentifier("SettingsNavigationController") as! UINavigationController
            hamburgerViewController?.contentViewController = settingsNavigationController
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
