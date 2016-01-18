//
//  NotificationsSettingsViewController.swift
//  XCHAT
//
//  Created by Jim Cai on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class SettingsViewController: ContentViewController, UITableViewDataSource, UITableViewDelegate, SwitchDelegate, LoggedOutDelegate {

    var savedSettings = [String: Bool]()
    var window: UIWindow?
    
    let kHeaderViewHeight = CGFloat(50)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenuButton(withColor: "white")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        default:
            return 2
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = NSBundle.mainBundle().loadNibNamed("SettingsHeaderView", owner: self, options: nil)[0] as! SettingsHeaderView
        switch section {
        case 0:
            headerView.headerLabel.text = "PUSH NOTIFICATIONS"
        default:
            headerView.headerLabel.text = "LOG OUT"
        }
        headerView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, headerView.frame.height)
        return headerView
    }
    
    
    /*
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "PUSH NOTIFICATIONS"
        default:
            return "LOG OUT"
        }
    }
    */
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kHeaderViewHeight
    }
    
    let settingsNames = ["Chat session started", "New photo uploaded"]
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = self.tableView.dequeueReusableCellWithIdentifier("SettingsDescriptionCell") as! SettingsDescriptionTableViewCell
                cell.setDescription("Select when you'd like to receive push notifications from THE DELT.")
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationTableViewCell
                cell.delegate = self
                cell.label.text =  self.settingsNames[indexPath.row - 1]
                if let switchOnValue = savedSettings[cell.label.text!] {
                    cell.onSwitch.setOn(switchOnValue, animated: true)
                } else {
                    cell.onSwitch.setOn(false, animated: true)
                }
                return cell
            }
        default:
            if indexPath.row == 0 {
                let cell = self.tableView.dequeueReusableCellWithIdentifier("SettingsDescriptionCell") as! SettingsDescriptionTableViewCell
                cell.setDescription("Hate to see you go! Come back soon.")
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("LogoutCell", forIndexPath: indexPath) as! LogOutTableViewCell
                cell.delegate = self
                return cell
            }
        }
    }
    
    func loggedOutDelegate(logoutTableViewCell: LogOutTableViewCell) {
        PFUser.logOut()
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = loginStoryboard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
        
        UIView.transitionWithView(self.view.window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.view.window!.rootViewController = loginViewController
        }, completion: nil)
    }
   
    func switchDelegate(switchtableViewCell: NotificationTableViewCell, switchValue: Bool) {
        savedSettings[switchtableViewCell.label.text!] = switchValue
        if switchValue{
            PushHelper.subscribeToChannel(switchtableViewCell.label.text!)
        }
        else{
            PushHelper.unsubscribeFromChannel(switchtableViewCell.label.text!)
            
        }
    }
    
}
