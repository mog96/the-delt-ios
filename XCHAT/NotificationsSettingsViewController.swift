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
    
    let kHeaderViewHeight = CGFloat(50)
    
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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "PUSH NOTIFICATIONS"
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kHeaderViewHeight
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
