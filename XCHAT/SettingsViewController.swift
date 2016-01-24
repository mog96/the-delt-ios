//
//  NotificationsSettingsViewController.swift
//  XCHAT
//
//  Created by Jim Cai on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: ContentViewController, UITableViewDataSource, UITableViewDelegate, SwitchDelegate, FeedbackDelegate, LoggedOutDelegate, MFMailComposeViewControllerDelegate {

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
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 2
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = NSBundle.mainBundle().loadNibNamed("SettingsHeaderView", owner: self, options: nil)[0] as! SettingsHeaderView
        switch section {
        case 0:
            headerView.headerLabel.text = "PUSH NOTIFICATIONS"
        case 1:
            headerView.headerLabel.text = "FEEDBACK"
        case 2:
            headerView.headerLabel.text = "REPORT USER"
        default:
            headerView.headerLabel.text = "LOG OUT"
        }
        headerView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, headerView.frame.height)
        return headerView
    }
    
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
        case 1:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("SettingsDescriptionCell") as! SettingsDescriptionTableViewCell
            cell.setDescription("Submit any comments or suggestions you may have to mateog@stanford.edu.")
            return cell
        case 2:
            if indexPath.row == 0 {
                let cell = self.tableView.dequeueReusableCellWithIdentifier("SettingsDescriptionCell") as! SettingsDescriptionTableViewCell
                cell.setDescription("Report any content you feel is inappropriate, or users you feel are abusing this service and should be blocked from THE DELT.")
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("FeedbackCell", forIndexPath: indexPath) as! FeedbackTableViewCell
                cell.feedbackButton.titleLabel?.text = "Report User"
                cell.delegate = self
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
    
    
    // MARK: - Feedback Mail Compose
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        // TODO: Handle each mail case? i.e. sent, not sent, etc.
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presentReportUserMailCompose() {
        if MFMailComposeViewController.canSendMail() {
            let subject = "THE DELT: Report User"
            let recipient = "mateog@stanford.edu"
            var body = "Name: "
            if let name = PFUser.currentUser()?.objectForKey("name") as? String {
                body += "\n" + name
            }
            if let username = PFUser.currentUser()?.username {
                body += "\n" + "Username: " + username
            }
            body += "\n\nUser in question: [enter username]"
            body += "\nComment: [optional]"
            
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setSubject(subject)
            mailComposeVC.setToRecipients([recipient])
            mailComposeVC.setMessageBody(body, isHTML: false)
            
            
            // mailComposeVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
            // UINavigationBar.appearance().barStyle = .Black
            
            self.presentViewController(mailComposeVC, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Mail Not Enabled", message: "Could not send message. Set up a mail account for your device and try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
