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
import MBProgressHUD

class SignupRequestsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tableViewPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var tableViewTapGestureRecognizer: UITapGestureRecognizer!
    
    var refreshControl: UIRefreshControl!
    
    var swipedCell: SignupRequestTableViewCell?
    var previousSwipedCell: SignupRequestTableViewCell?
    var infoViewOriginalOrigin = CGPoint.zero
    
    var signupRequests = [PFObject]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 95
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(self.onRefresh), for: UIControlEvents.valueChanged)
        self.refreshControl.tintColor = LayoutUtils.blueColor
        self.tableView.insertSubview(refreshControl, at: 0)
        
        self.fetchSignupRequests()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.appDelegate.hamburgerViewController?.panGestureRecognizer.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.appDelegate.hamburgerViewController?.panGestureRecognizer.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Helpers

extension SignupRequestsViewController {
    func fetchSignupRequests() {
        let query = PFQuery(className: "SignupRequest")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error != nil {
                print("Error:", error!.localizedDescription)
            } else {
                if let objects = objects {
                    self.signupRequests = objects
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func onRefresh() {
        self.fetchSignupRequests()
    }
}


// MARK: - Table View

extension SignupRequestsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.signupRequests.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SignupRequestCell") as! SignupRequestTableViewCell
        cell.setupCell(signupRequest: self.signupRequests[indexPath.row])
        cell.delegate = self
        return cell
    }
}


// MARK: - Edit User Cell Delegate

extension SignupRequestsViewController: SignupRequestTableViewCellDelegate {
    func signupRequestTableViewCell(didApproveUser object: PFObject) {
        let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        currentHUD.label.text = "Approving User..."
        
        /*
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
                currentHUD.label.text = "Approved!"
                currentHUD.hideAnimated(true, afterDelay: 1.0)
                self.resetTableView()
                
                // PRESENT MAIL COMPOSE TO NOTIFY USER/EXPLAIN PASSWORD RESET
                self.presentSignupApprovedMailCompose(forUser: user)
                object.deleteInBackgroundWithBlock({ (completed: Bool, error: NSError?) in
                    if error != nil {
                        print("Error:", error?.userInfo["error"])
                    } else {
                        print("USER", user.username, "DELETED")
                        self.fetchSignupRequests()
                        self.refreshControl.beginRefreshing()
                    }
                })
            }
        }
        */
        
        let approvedUser = ["name": object["name"],
                            "email": object["email"],
                            "username": object["username"],
                            "tempPass": "temp"]
        // PFCloud.callFunction(inBackground: "approveUser", withParameters: approvedUser,
        PFCloud.callFunction(inBackground: "approveUser", withParameters: approvedUser) { (createdUser: Any?, error: Error?) in
            if error != nil {
                print("Error:", error!.localizedDescription)
                currentHUD.hide(animated: true)
            } else {
                if let user = createdUser as? PFUser {
                    currentHUD.label.text = "Approved!"
                    currentHUD.hide(animated: true, afterDelay: 1.0)
                    
                    self.presentSignupApprovedMailCompose(forUser: user)
                    object.deleteInBackground(block: { (completed: Bool, error: Error?) in
                        if error != nil {
                            print("Error:", error!.localizedDescription)
                        } else {
                            print("USER", user.username, "DELETED")
                            self.fetchSignupRequests()
                            self.refreshControl.beginRefreshing()
                        }
                    })
                } else {
                    print("ERROR RETRIEVING NEW USER.")
                }
            }
            self.resetTableView()
        }
    }
}


// MARK: - Mail Compose View Controller Delegate

extension SignupRequestsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // TODO: Handle each mail case? i.e. sent, not sent, etc.
        
        controller.dismiss(animated: true) {
            if result == .sent {
                let alert = UIAlertController(title: "Thanks for Signing Up!", message: "If your charge has already been added to The Delt, you'll be added immediately. If your charge is not yet using The Delt, we'll be in touch as soon as possible about signing up your charge.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func presentSignupApprovedMailCompose(forUser user: PFUser) {
        if MFMailComposeViewController.canSendMail() {
            let subject = "Signup Request Approved - " + AppDelegate.appName
            let bccRecipient = "thedeltusa@gmail.com"
            var body = "Hi \(user["name"]),\n\nWelcome to The Delt. Your login information is as follows:\n\n"
            body += "Username: \(user.username!)\n"
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
            
            self.present(mailComposeVC, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Mail Not Enabled", message: "Could not send signup approval message. Please set up a mail account for your device and try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}


// MARK: - Actions

extension SignupRequestsViewController {
    @IBAction func onPanGesture(_ sender: AnyObject) {
        let location = sender.location(in: self.tableView)
        let translation = sender.translation(in: self.tableView)
        let velocity = sender.velocity(in: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: location) {
            if sender.state == .began {
                self.swipedCell = self.tableView.cellForRow(at: indexPath) as? SignupRequestTableViewCell
                if self.previousSwipedCell == nil {
                    self.previousSwipedCell = self.swipedCell
                }
                
                if self.swipedCell == self.previousSwipedCell {
                    self.infoViewOriginalOrigin = self.previousSwipedCell!.infoView.frame.origin
                } else {
                    self.resetTableView()
                }
                
            } else if sender.state == .changed {
                self.previousSwipedCell?.infoView.frame.origin.x = self.infoViewOriginalOrigin.x + translation.x
                
            } else if sender.state == .ended {
                if velocity.x < 0 {
                    self.previousSwipedCell?.showApproveButton()
                    self.tableView.isScrollEnabled = false
                    self.tableViewTapGestureRecognizer.isEnabled = true
                } else {
                    self.resetTableView()
                }
            }
        }
    }
    
    @IBAction func onViewTapped(_ sender: AnyObject) {
        self.resetTableView()
    }
    
    func resetTableView() {
        self.previousSwipedCell?.hideApproveButton()
        self.previousSwipedCell = nil
        self.tableView.isScrollEnabled = true
        self.tableViewTapGestureRecognizer.isEnabled = false
    }
}
