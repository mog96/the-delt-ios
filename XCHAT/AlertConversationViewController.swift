//
//  AlertConversationViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/25/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

// TODO: Incorporates reply view at the bottom.

protocol AlertConversationViewControllerDelegate {
    func alertConversationViewController(didUpdateAlert alert: PFObject)
}

class AlertConversationViewController: ContentViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deltLoadingView: DeltLoadingView!
    var refreshControl = UIRefreshControl()
    
    var delegate: AlertConversationViewControllerDelegate?
    var alert: PFObject!
    var replies = [PFObject]()
    var shouldScrollToBottom = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 10
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: "AlertDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "AlertDetailCell")
        self.tableView.register(UINib(nibName: "AlertReplyTableViewCell", bundle: nil), forCellReuseIdentifier: "AlertReplyCell")
        
        self.deltLoadingView.deltColor = UIColor.white
        
        self.firstLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.shouldScrollToBottom {
            let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 1) - 1, section: 1)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            self.shouldScrollToBottom = false
        }
    }
}

// In query for AlertReply objects, include key User


// MARK: - Refresh Helpers

extension AlertConversationViewController {
    func firstLoad() {
        let animationDuration = 0.5
        UIView.transition(with: self.deltLoadingView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
            self.deltLoadingView.startAnimating()
            self.deltLoadingView.isHidden = false
        }, completion: nil)
        self.refreshReplies {
            UIView.transition(with: self.deltLoadingView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
                self.deltLoadingView.isHidden = true
                self.deltLoadingView.stopAnimating()
            }, completion: nil)
        }
    }
    
    func refreshReplies(completion: (() -> ())?) {
        self.getReplies { (replies: [PFObject]?) in
            if let replies = replies {
                DispatchQueue.main.async(execute: {
                    // print("REPLIES:", replies)
                    self.replies = replies
                    // self.tableView.contentOffset = CGPoint.zero
                    self.tableView.reloadData()
                    // self.noUpcomingEventsLabel.isHidden = self.events.count != 0
                })
            }
            completion?()
        }
    }
    
    func getReplies(completion: @escaping (([PFObject]?) -> ())) {
        if let alertObjectId = self.alert.objectId {
            let query = PFQuery(className: "Alert")
            query.includeKeys(["replies", "replies.author"])
            query.whereKey("objectId", equalTo: alertObjectId)
            query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
                if let alert = objects?[0] {
                    let replies = alert["replies"] as? [PFObject]
                    
                    print("REPLIES:", replies)
                    
                    completion(replies)
                } else {
                    print("object is nil")
                    print(error!.localizedDescription)
                }
            }
        } else {
            print("ALERT OBJECT ID NOT FOUND")
        }
    }
}


// MARK: - Table View

extension AlertConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if replies.count > 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default: // case 1:
            return self.replies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let detailCell = tableView.dequeueReusableCell(withIdentifier: "AlertDetailCell", for: indexPath) as! AlertDetailTableViewCell
            detailCell.setUpCell(alert: self.alert)
            detailCell.delegate = self
            return detailCell
        default:
            let replyCell = tableView.dequeueReusableCell(withIdentifier: "AlertReplyCell", for: indexPath) as! AlertReplyTableViewCell
            replyCell.setUpCell(reply: self.replies[indexPath.row])
            replyCell.delegate = self
            replyCell.indexPath = indexPath
            return replyCell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


// MARK: - Alert Detail Cell Delegate

extension AlertConversationViewController: AlertDetailTableViewCellDelegate {
    func alertDetailTableViewCell(updateFaved faved: Bool) {
        AlertUtils.updateFaved(forAlert: self.alert, faved: faved) { (savedAlert: PFObject?, error: Error?) in
            if let error = error {
                print("Error: \(error) \(error.localizedDescription)")
            } else if let updatedAlert = savedAlert {
                self.updateAlertDetailCell(updatedAlert: updatedAlert)
                self.delegate?.alertConversationViewController(didUpdateAlert: updatedAlert)
            }
        }
    }
    
    func alertDetailTableViewCellReplyToAlert() {
        self.presentAlertReplyViewController()
    }
    
    func alertDetailTableViewCell(updateFlagged flagged: Bool) {
        AlertUtils.updateFlagged(forAlert: self.alert, flagged: flagged) { (savedAlert: PFObject?, error: Error?) in
            if let error = error {
                self.presentFlaggedAlert(withError: true)
                print("Error: \(error) \(error.localizedDescription)")
            } else if let updatedAlert = savedAlert {
                if flagged {
                    self.presentFlaggedAlert(withError: false)
                }
                self.updateAlertDetailCell(updatedAlert: updatedAlert)
                self.delegate?.alertConversationViewController(didUpdateAlert: updatedAlert)
            }
        }
    }
}


// MARK: - Alert Update Helpers

extension AlertConversationViewController {
    fileprivate func updateAlertDetailCell(updatedAlert: PFObject) {
        self.alert = updatedAlert
        let indexPath = IndexPath(row: 0, section: 0)
        if let _ = self.tableView.cellForRow(at: indexPath) {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    fileprivate func presentFlaggedAlert(withError error: Bool) {
        if error {
            let alert = UIAlertController(title: "Server Error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Post Flagged", message: "Administrators have been notified and this post will be reviewed.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


// MARK: - Alert Reply Cell Delegate

extension AlertConversationViewController: AlertReplyTableViewCellDelegate {
    func alertReplyTableViewCell(updateFavedForReply reply: PFObject?, atIndexPath indexPath: IndexPath, faved: Bool) {
        if let reply = reply {
            self.updateFaved(forReply: reply, faved: faved) { (savedReply: PFObject?, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let updatedReply = savedReply {
                    self.reloadReplyCell(updatedReply: updatedReply, atIndexPath: indexPath)
                }
            }
        }
    }
    
    func alertReplyTableViewCell(replyToReply reply: PFObject?) {
        
        // TODO: @username for reply to user as well
        
        self.presentAlertReplyViewController()
    }
    
    func alertReplyTableViewCell(updateFlaggedForReply reply: PFObject?, atIndexPath indexPath: IndexPath, flagged: Bool) {
        if let reply = reply {
            self.updateFlagged(forReply: reply, flagged: flagged, completion: { (savedReply: PFObject?, error: Error?) in
                if let error = error {
                    self.presentFlaggedAlert(withError: true)
                    print(error.localizedDescription)
                } else if let updatedReply = savedReply {
                    if flagged {
                        self.presentFlaggedAlert(withError: false)
                    }
                    self.reloadReplyCell(updatedReply: updatedReply, atIndexPath: indexPath)
                }
            })
        } else {
            self.presentFlaggedAlert(withError: true)
        }
    }
}


// MARK: - Reply Update Helpers

extension AlertConversationViewController {
    fileprivate func reloadReplyCell(updatedReply: PFObject, atIndexPath indexPath: IndexPath) {
        self.replies[indexPath.row] = updatedReply
        // Check that cell exists (i.e. we are not in the middle of an alerts refresh).
        if let _ = self.tableView.cellForRow(at: indexPath) {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    fileprivate func updateFaved(forReply reply: PFObject, faved: Bool, completion: ((PFObject?, Error?) -> ())?) {
        let query = PFQuery(className: "AlertReply")
        if let objectId = reply.objectId {
            query.getObjectInBackground(withId: objectId) { (fetchedReply: PFObject?, error: Error?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                } else if let updatedReply = fetchedReply {
                    if let username = PFUser.current()?.username {
                        // Increment or decrement fave count accordingly.
                        if faved {
                            updatedReply.addUniqueObject(username, forKey: "favedBy")
                            updatedReply.incrementKey("faveCount")
                        } else {
                            updatedReply.remove(username, forKey: "favedBy")
                            updatedReply.incrementKey("faveCount", byAmount: -1)
                        }
                    }
                    updatedReply.saveInBackground(block: { (completed: Bool, error: Error?) -> Void in
                        completion?(updatedReply, error)
                    })
                }
            }
        }
    }
    
    fileprivate func updateFlagged(forReply reply: PFObject, flagged: Bool, completion: ((PFObject?, Error?) -> ())?) {
        let query = PFQuery(className: "AlertReply")
        if let objectId = reply.objectId {
            query.getObjectInBackground(withId: objectId) { (fetchedReply: PFObject?, error: Error?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                } else if let updatedReply = fetchedReply {
                    if let username = PFUser.current()?.username {
                        // Increment or decrement fave count accordingly.
                        if flagged {
                            updatedReply.addUniqueObject(username, forKey: "flaggedBy")
                            updatedReply.incrementKey("flagCount")
                        } else {
                            updatedReply.remove(username, forKey: "flaggedBy")
                            updatedReply.incrementKey("flagCount", byAmount: -1)
                        }
                    }
                    updatedReply.saveInBackground(block: { (completed: Bool, error: Error?) -> Void in
                        completion?(updatedReply, error)
                    })
                }
            }
        }
    }
}


// MARK: - Reply

extension AlertConversationViewController {
    fileprivate func presentAlertReplyViewController() {
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let alertReplyNC = storyboard.instantiateViewController(withIdentifier: "AlertReplyNC") as! UINavigationController
        let alertReplyVC = alertReplyNC.viewControllers[0] as! AlertReplyViewController
        alertReplyVC.replyToAlert = self.alert
        alertReplyVC.delegate = self
        self.present(alertReplyNC, animated: true, completion: nil)
    }
}


// MARK: - Alert Compose VC Delegate

extension AlertConversationViewController: AlertComposeViewControllerDelegate {
    // Append new reply to bottom of alert conversation.
    func refreshData(savedObject object: AnyObject?, completion: @escaping (() -> ())) {
        if let newReply = object as? PFObject {
            self.replies.append(newReply)
            self.tableView.reloadData()
            self.shouldScrollToBottom = true
            
            self.alert["replies"] = self.replies
            if self.alert["replyCount"] == nil {
                self.alert["replyCount"] = 0
            }
            self.alert["replyCount"] = self.alert["replyCount"] as! Int + 1
            self.delegate?.alertConversationViewController(didUpdateAlert: self.alert)
        }
        completion()
    }
}


// MARK: - Actions

extension AlertConversationViewController {
    @IBAction func onReplyButtonTapped(_ sender: Any) {
        self.presentAlertReplyViewController()
    }
}
