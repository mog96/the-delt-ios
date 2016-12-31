//
//  AlertConversationViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/25/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//






// TODO: ADD REPLY TO RELIES ARRAY BEFORE AFTER SAVE UPDATE TO ALERT OBJ GOES THRU










import UIKit
import Parse
import ParseUI

// TODO: Incorporates reply view at the bottom.

class AlertConversationViewController: ContentViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deltLoadingView: DeltLoadingView!
    
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


// MARK: - Helpers

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


// MARK: - Reply Helpers

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
            replyCell.alert = self.alert
            replyCell.setUpCell(reply: self.replies[indexPath.row])
            replyCell.delegate = self
            return replyCell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


// MARK: - Alert Detail Cell Delegate

extension AlertConversationViewController: AlertDetailTableViewCellDelegate {
    func alertDetailTableViewCellDidTapReply() {
        self.presentAlertReplyViewController()
    }
}


// MARK: - Alert Reply Cell Delegate

extension AlertConversationViewController: AlertReplyTableViewCellDelegate {
    func alertDetailTableViewCell(updateFaved faved: Bool) {
        // USE INSTANCE FACTORY
    }
    
    func alertReplyTableViewCellDidTapReply() {
        self.presentAlertReplyViewController()
    }
    
    func alertDetailTableViewCell(updateFlagged flagged: Bool) {
        // USE INSTANCE FACTORY
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
