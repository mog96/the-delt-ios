//
//  SignupRequestsViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/28/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class SignupRequestsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tableViewPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var tableViewTapGestureRecognizer: UITapGestureRecognizer!
    
    var refreshControl: UIRefreshControl!
    
    var swipedCell: SignupRequestTableViewCell?
    var previousSwipedCell: SignupRequestTableViewCell?
    var infoViewOriginalOrigin = CGPointZero
    
    var signupRequests = [PFObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableViewPanGestureRecognizer.enabled = false
        self.tableViewTapGestureRecognizer.enabled = false
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(ReelViewController.onRefresh), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl.tintColor = LayoutUtils.blueColor
        self.tableView.insertSubview(refreshControl, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Helpers

extension SignupRequestsViewController {
    func fetchSignupRequests() {
        let query = PFQuery(className: "SignupRequests")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if error != nil {
                print("Error:", error?.userInfo["error"])
            } else {
                if let objects = objects {
                    self.signupRequests = objects
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func onRefresh() {
        self.fetchSignupRequests()
        self.refreshControl.endRefreshing()
    }
}


// MARK: - Table View

extension SignupRequestsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.signupRequests.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SignupRequestCell") as! SignupRequestTableViewCell
        cell.setupCell(signupRequest: self.signupRequests[indexPath.row])
        return cell
    }
}


// MARK: - Edit User Cell Delegate

extension SignupRequestsViewController: SignupRequestTableViewCellDelegate {
    func signupRequestTableViewCell(didApproveUser object: PFObject) {
        let user = PFUser()
        user["name"] = object["name"] as? String
        user.email = object["email"] as? String
        user.username = object["username"] as? String
        user.password = "temp"
        user["totalNumFavesReceived"] = 0
        user["totalNumPhotosPosted"] = 0
        
        user.signUpInBackgroundWithBlock { (completed: Bool, error: NSError?) in
            if error != nil {
                print("ERROR:", error)
            } else {
                print("YES")
                
                // PRESENT MAIL COMPOSE TO NOTIFY USER/EXPLAIN PASSWORD RESET
                self.presentSignupApprovedMailCompose(forUser: user)
            }
        }
    }
}


// MARK: - Mail Compose View Controller Delegate

extension SignupRequestsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        // TODO: Handle each mail case? i.e. sent, not sent, etc.
        
        controller.dismissViewControllerAnimated(true) {
            if result == .Sent {
                let alert = UIAlertController(title: "Thanks for Signing Up!", message: "If your charge has already been added to The Delt, you'll be added immediately. If your charge is not yet using The Delt, we'll be in touch as soon as possible about signing up your charge.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func presentSignupApprovedMailCompose(forUser user: PFUser) {
        if MFMailComposeViewController.canSendMail() {
            let subject = "Signup Request Approved - " + AppDelegate.appName
            let bccRecipient = "thedeltusa@gmail.com"
            var body = "Hi \(user["name"]),\n\nWelcome to The Delt. Your login information is as follows:\n\n"
            body += "Username: \(user.username)\n"
            body += "Password: temp\n\n"
            body += "You may reset your password upon login.\n\n" // TODO: Embed link to thedelt://
            body += "Warm regards,\nPledge Mike"
            
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setSubject(subject)
            if let recipient = user.email {
                mailComposeVC.setToRecipients([recipient])
            }
            mailComposeVC.setBccRecipients([bccRecipient])
            mailComposeVC.setMessageBody(body, isHTML: false)
            
            self.presentViewController(mailComposeVC, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Mail Not Enabled", message: "Could not send signup approval message. Please set up a mail account for your device and try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}


// MARK: - Actions

extension SignupRequestsViewController {
    @IBAction func onPanGesture(sender: AnyObject) {
        let location = sender.locationInView(self.tableView)
        let translation = sender.translationInView(self.tableView)
        let velocity = sender.velocityInView(self.tableView)
        
        if let indexPath = self.tableView.indexPathForRowAtPoint(location) {
            if sender.state == .Began {
                self.swipedCell = self.tableView.cellForRowAtIndexPath(indexPath) as? SignupRequestTableViewCell
                if self.previousSwipedCell == nil {
                    self.previousSwipedCell = self.swipedCell
                }
                
                if self.swipedCell == self.previousSwipedCell {
                    self.infoViewOriginalOrigin = self.previousSwipedCell!.infoView.frame.origin
                } else {
                    self.resetTableView()
                }
                
            } else if sender.state == .Changed {
                self.previousSwipedCell?.infoView.frame.origin.x = self.infoViewOriginalOrigin.x + translation.x
                
            } else if sender.state == .Ended {
                if velocity.x < 0 {
                    self.previousSwipedCell?.showApproveButton()
                    self.tableView.scrollEnabled = false
                    self.tableViewTapGestureRecognizer.enabled = true
                } else {
                    self.resetTableView()
                }
            }
        }
    }
    
    @IBAction func onTableViewTapped(sender: AnyObject) {
        self.resetTableView()
    }
    
    func resetTableView() {
        self.previousSwipedCell?.hideApproveButton()
        self.previousSwipedCell = nil
        self.tableView.scrollEnabled = true
        self.tableViewTapGestureRecognizer.enabled = false
    }
}
