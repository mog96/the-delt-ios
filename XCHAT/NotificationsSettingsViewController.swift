//
//  NotificationsSettingsViewController.swift
//  XCHAT
//
//  Created by Jim Cai on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class NotificationsSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchDelegate, LoggedOutDelegate {

    var savedSettings = [String: Bool]()
    var window: UIWindow?
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 20))
        headerView.backgroundColor = UIColor(white: 3, alpha: 0.5)
        
        var notificationsLabel = UILabel(frame: CGRect(x: 8 , y: 2, width: 200, height: 16))
        notificationsLabel.text = "PUSH NOTIFICATIONS"
        notificationsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 14)
        notificationsLabel.textColor = UIColor.redColor()
        notificationsLabel.sizeToFit()
        
        headerView.insertSubview(notificationsLabel, atIndex: 0)
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < 3 {
            var cell = tableView.dequeueReusableCellWithIdentifier("NTCell", forIndexPath: indexPath) as! NotificationsTableViewCell
            cell.delegate = self

            cell.label.text =  NotificationSettingConstants.settingsList[indexPath.row]
            if let switchOnValue=savedSettings[cell.label.text!]{
                cell.onSwitch.setOn(switchOnValue, animated: true)
            }else{
                cell.onSwitch.setOn(true, animated: true)
            }
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("LogoutCell", forIndexPath: indexPath) as! LogOutTableViewCell
            cell.delegate = self
            return cell
        }
    }
    
    func loggedOutDelegate(logoutTableViewCell: LogOutTableViewCell) {
        PFUser.logOut()
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var loginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
        
        // Does exactly the same as arrow in storyboard. ("100% parity." --Tim Lee)
        view.window?.rootViewController = loginViewController
    }
   
    func switchDelegate(switchtableViewCell: NotificationsTableViewCell, switchValue: Bool) {
        savedSettings[switchtableViewCell.label.text!] = switchValue
        if switchValue{
            PushHelper.subscribeToChannel(switchtableViewCell.label.text!)
        }
        else{
            PushHelper.unsubscribeFromChannel(switchtableViewCell.label.text!)
            
        }
    }
    
}
