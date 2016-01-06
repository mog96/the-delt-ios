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
        
        self.tableView.canCancelContentTouches = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell")!
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell")!
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("ReelCell")!
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("CalendarCell")!
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("MembersCell")!
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell")!
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
        case 0: // PROFILE
            let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
            let profileController = profileStoryboard.instantiateViewControllerWithIdentifier("ProfileNavigationController") as! UINavigationController
            
            hamburgerViewController?.contentViewController = profileController
            
        case 1: // CHAT
            let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
            let chatNavigationController = chatStoryboard.instantiateViewControllerWithIdentifier("ChatNavigationController") as! UINavigationController
            
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
            hamburgerViewController?.contentViewController = chatNavigationController
            
        case 2: // REEL
            let reelStoryboard = UIStoryboard(name: "Reel", bundle: nil)
            let reelNavigationController = reelStoryboard.instantiateViewControllerWithIdentifier("ReelNavigationController") as! UINavigationController
            
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
            hamburgerViewController?.contentViewController = reelNavigationController
            
        case 3: // CALENDAR
            let eventsStoryboard = UIStoryboard(name: "Calendar", bundle: nil)
            let eventsNavigationController = eventsStoryboard.instantiateViewControllerWithIdentifier("Nav") as! UINavigationController
            
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
            hamburgerViewController?.contentViewController = eventsNavigationController
            
        case 4: // MEMBERS
            let storyboard = UIStoryboard(name: "Members", bundle: nil)
            let nc = storyboard.instantiateViewControllerWithIdentifier("Members") as! UINavigationController
            let membersViewController = nc.viewControllers.first as! MembersViewController
            membersViewController.hamburgerViewController = self.hamburgerViewController
            
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
            hamburgerViewController?.contentViewController = nc
            
        default: // SETTINGS
            let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
            let settingsNavigationController = settingsStoryboard.instantiateViewControllerWithIdentifier("SettingsNavigationController") as! UINavigationController
            
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
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
