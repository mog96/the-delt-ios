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

class AlertConversationViewController: ContentViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deltLoadingView: DeltLoadingView!
    
    var alert: PFObject!
    var replies = [PFObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 10
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.deltLoadingView.deltColor = UIColor.white
        
        self.firstLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if let replyToUser = self.alert["author"] as? PFUser {
            let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
            let alertReplyNC = storyboard.instantiateViewController(withIdentifier: "AlertReplyNC") as! UINavigationController
            let alertReplyVC = alertReplyNC.viewControllers[0] as! AlertReplyViewController
            alertReplyVC.alert = self.alert
            alertReplyVC.replyToUser = replyToUser
            alertReplyVC.delegate = self
            self.present(alertReplyNC, animated: true, completion: nil)
        }
    }
}


// MARK: - Table View

extension AlertConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default: // case 1:
            return replies.count
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
}


// MARK: - Alert Detail Cell Delegate

extension AlertConversationViewController: AlertDetailTableViewCellDelegate {
    func alertDetailTableViewCellDidTapReply() {
        self.presentAlertReplyViewController()
    }
}


// MARK: - Alert Reply Cell Delegate

extension AlertConversationViewController: AlertReplyTableViewCellDelegate {
    func alertReplyTableViewCellDidTapReply() {
        self.presentAlertReplyViewController()
    }
}


// MARK: - Alert Compose VC Delegate

extension AlertConversationViewController: AlertComposeViewControllerDelegate {
    func refreshData(completion: @escaping (() -> ())) {
        self.refreshReplies { 
            completion()
        }
    }
}


// MARK: - Actions

extension AlertConversationViewController {
    @IBAction func onReplyButtonTapped(_ sender: Any) {
        self.presentAlertReplyViewController()
    }
}
