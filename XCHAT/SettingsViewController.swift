//
//  NotificationsSettingsViewController.swift
//  XCHAT
//
//  Created by Jim Cai on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import MBProgressHUD
import MessageUI
import Parse

class SettingsViewController: ContentViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var savedSettings = [String: Bool]()
    var window: UIWindow?
    
    let settingsNames = ["Chat session started", "New photo uploaded"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        self.setMenuButton(withColor: "white")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
}


// MARK: - Helpers

/*
extension SettingsViewController {
    func loginFacebookRead() {
        FBSDKLoginManager().logInWithReadPermissions([""], fromViewController: <#T##UIViewController!#>, handler: <#T##FBSDKLoginManagerRequestTokenHandler!##FBSDKLoginManagerRequestTokenHandler!##(FBSDKLoginManagerLoginResult!, NSError!) -> Void#>)
        User.readingLoginManager.logInWithPublishPermissions(["publish_actions", "manage_pages", "publish_pages"], fromViewController: self, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if(error != nil){
                
            }
            if !self.hasPublishingCredentials(){
                let alert = UIAlertController(title: "Facebook Permissions", message: "Please grant publishing permissions to share photos", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Alright", style: .Default, handler: { (action:UIAlertAction) -> Void in
                    self.postingLoader!.facebookSwitch.selected = false
                }))
                self.presentViewController(alert, animated: true, completion: { () -> Void in
                })
                return
            }else{
                if self.captionMode == CaptionMode.Text{
                    self.facebookShareText()
                }else{
                    if self.captured_url != nil{
                        self.facebookShareVideo()
                        self.facebookName.hidden = true
                    }else{
                        self.facebookSharePhoto()
                        self.facebookName.hidden = true
                    }
                }
            }
            }
        )
    }
}
*/


// MARK: - Table View

// NOTE: Push notification settings commented out.

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        // return 4
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        /*
        case 0:
            return 3
        */
        case 0:
            return 2
        case 1:
            return 2
        default:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("SettingsHeaderView", owner: self, options: nil)![0] as! SettingsHeaderView
        switch section {
        /*
        case 0:
            headerView.headerLabel.text = "PUSH NOTIFICATIONS"
        */
        case 0:
            headerView.headerLabel.text = "FEEDBACK"
        case 1:
            headerView.headerLabel.text = "REPORT CONTENT OR USER"
        default:
            headerView.headerLabel.text = "LOG OUT"
        }
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerView.frame.height)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        /*
        case 0:
            if indexPath.row == 0 {
                let cell = NSBundle.mainBundle().loadNibNamed("SettingsDescriptionTableViewCell", owner: self, options: nil)![0] as! SettingsDescriptionTableViewCell
                cell.setDescription("Select when you'd like to receive push notifications from The Delt.")
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
        */
        case 0:
            switch indexPath.row {
            case 0:
                let cell = Bundle.main.loadNibNamed("SettingsDescriptionTableViewCell", owner: self, options: nil)![0] as! SettingsDescriptionTableViewCell
                cell.setDescription("Submit any comments or suggestions you may have to mateog@stanford.edu.")
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath) as! FeedbackTableViewCell
                cell.delegate = self
                return cell
            }
        case 1:
            if indexPath.row == 0 {
                let cell = Bundle.main.loadNibNamed("SettingsDescriptionTableViewCell", owner: self, options: nil)![0] as! SettingsDescriptionTableViewCell
                cell.setDescription("Report any content you feel is inappropriate, or users you feel are abusing this service and should be blocked from The Delt.")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath) as! FeedbackTableViewCell
                cell.feedbackButton.setTitle("Report Content or User", for: UIControlState())
                cell.delegate = self
                return cell
            }
        default:
            if indexPath.row == 0 {
                let cell = Bundle.main.loadNibNamed("SettingsDescriptionTableViewCell", owner: self, options: nil)![0] as! SettingsDescriptionTableViewCell
                cell.setDescription("Hate to see you go! Come back soon.")
                return cell
            } else {
                let cell = Bundle.main.loadNibNamed("ActionButtonTableViewCell", owner: self, options: nil)![0] as! ActionButtonTableViewCell
                cell.delegate = self
                cell.actionButton.setTitle("Log Out", for: UIControlState())
                return cell
            }
        }
    }
}


// MARK: - Log Out Delegate

extension SettingsViewController: ActionButtonCellDelegate {
    func actionButtonCell(tappedBySender sender: AnyObject) {
        let alertVC = UIAlertController(title: "Log Out?", message: "Hate to see you go.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)
        if #available(iOS 9.0, *) {
            alertVC.preferredAction = cancelAction
        }
        alertVC.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (action: UIAlertAction) in
            let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            currentHUD.label.text = "Logging Out..."
            PFUser.logOutInBackground(block: { (error: Error?) in
                if let error = error {
                    print("LOG OUT ERROR ", error._code,":", error.localizedDescription)
                }
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
                let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
                
                UserDefaults(suiteName: "group.com.tdx.thedelt")?.removeObject(forKey: "Username")
                
                UIView.transition(with: self.view.window!, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                    self.view.window!.rootViewController = loginViewController
                    }, completion: nil)
            })
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
}


// MARK: - Switch Delegate

extension SettingsViewController: SwitchDelegate {
    func switchDelegate(_ switchtableViewCell: NotificationTableViewCell, switchValue: Bool) {
        savedSettings[switchtableViewCell.label.text!] = switchValue
        if switchValue{
            // PushHelper.subscribeToChannel(switchtableViewCell.label.text!)
        }
        else{
            // PushHelper.unsubscribeFromChannel(switchtableViewCell.label.text!)
            
        }
    }
}


// MARK: - Feedback Mail Compose

extension SettingsViewController: MFMailComposeViewControllerDelegate, FeedbackDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // TODO: Handle each mail case? i.e. sent, not sent, etc.
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sendFeedback(type feedbackType: FeedbackType) {
        if MFMailComposeViewController.canSendMail() {
            var subject = ""
            let recipient = "mateog@stanford.edu"
            var body = ""
            
            switch feedbackType {
            case .reportUser:
                subject = "Report User - " + AppDelegate.appName
                body = "Name: "
                if let name = PFUser.current()?.object(forKey: "name") as? String {
                    body += name
                }
                body += "\n" + "Username: "
                if let username = PFUser.current()?.username {
                    body += username
                }
                body += "\n\nUser in question: [enter username]"
                body += "\nComment: [optional]"
                
            default:
                subject = "Feedback - " + AppDelegate.appName
                body = "Name: "
                if let name = PFUser.current()?.object(forKey: "name") as? String {
                    body += name
                }
                body += "\n" + "Username: "
                if let username = PFUser.current()?.username {
                    body += username
                }
                body += "\nFeedback: "
            }
            
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setSubject(subject)
            mailComposeVC.setToRecipients([recipient])
            mailComposeVC.setMessageBody(body, isHTML: false)
            
            
            // mailComposeVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
            // UINavigationBar.appearance().barStyle = .Black
            
            self.present(mailComposeVC, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Mail Not Enabled", message: "Could not send message. Set up a mail account for your device and try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
