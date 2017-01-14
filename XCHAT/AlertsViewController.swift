//
//  AlertsViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/23/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class AlertsViewController: ContentViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deltLoadingView: DeltLoadingView!
    @IBOutlet weak var blueModeButton: UIBarButtonItem!
    
    var refreshControl = UIRefreshControl()
    
    var alerts = [PFObject]()
    var selectedAlertIndexPath = IndexPath()
    var navgationBarOriginalTintColor: UIColor?
    
    var blueMode = false {
        didSet {
            if self.blueMode {
                self.blueModeButton.title = "red mode"
                self.blueModeButton.tintColor = .red
                self.setMenuButton(withColor: "red")
                self.navigationController?.navigationBar.barTintColor = self.navgationBarOriginalTintColor
                self.view.backgroundColor = self.navgationBarOriginalTintColor
            } else {
                self.blueModeButton.title = "blue mode"
                self.blueModeButton.tintColor = self.navgationBarOriginalTintColor
                self.setMenuButton(withColor: "blue")
                self.navigationController?.navigationBar.barTintColor = .red
                self.view.backgroundColor = .red
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenuButton(withColor: "blue")
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        
        self.navgationBarOriginalTintColor = self.blueModeButton.tintColor

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 10
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: "AlertTableViewCell", bundle: nil), forCellReuseIdentifier: "AlertCell")
        
        self.refreshControl.addTarget(self, action: #selector(self.onRefresh), for: UIControlEvents.valueChanged)
        self.refreshControl.tintColor = UIColor.white
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = self.refreshControl
        } else {
            self.tableView.insertSubview(self.refreshControl, at: 0)
        }
        
        self.deltLoadingView.deltColor = UIColor.white
        
        self.firstLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Refresh Helpers

extension AlertsViewController {
    func firstLoad() {
        let animationDuration = 0.5
        UIView.transition(with: self.deltLoadingView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
            self.deltLoadingView.startAnimating()
            self.deltLoadingView.isHidden = false
        }, completion: nil)
        self.refreshAlerts {
            UIView.transition(with: self.deltLoadingView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
                self.deltLoadingView.isHidden = true
                self.deltLoadingView.stopAnimating()
            }, completion: nil)
        }
    }
    
    func refreshAlerts(completion: (() -> ())?) {
        self.getAlerts { (alerts: [PFObject]) in
            DispatchQueue.main.async(execute: {
                print("ALERTS:", alerts)
                self.alerts = alerts
                // self.tableView.contentOffset = CGPoint.zero
                self.tableView.reloadData()
                // self.noUpcomingEventsLabel.isHidden = self.events.count != 0
            })
            completion?()
        }
    }
    
    func getAlerts(completion: @escaping (([PFObject]) -> ())) {
        let query = PFQuery(className: "Alert")
        query.includeKey("author")
        query.includeKey("photo")
        query.includeKey("author.photo")
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if let objects = objects {
                completion(objects)
            } else {
                print("object is nil")
                print(error!.localizedDescription)
            }
        }
    }
}


// MARK: - Table View

extension AlertsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.alerts.count, "ALERTS")
        return self.alerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertTableViewCell
        cell.nameLabel.profilePresenterDelegate = self
        cell.profileImageView.profilePresenterDelegate = self
        cell.setUpCell(alert: self.alerts[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedAlertIndexPath = indexPath
        
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let alertReplyNC = storyboard.instantiateViewController(withIdentifier: "AlertConversationNC") as! UINavigationController
        let alertConversationVC = alertReplyNC.viewControllers[0] as! AlertConversationViewController
        let alert = self.alerts[indexPath.row]
        alertConversationVC.alert = alert
        alertConversationVC.delegate = self
        self.navigationController?.pushViewController(alertConversationVC, animated: true)
    }
}


// MARK: - Alert Compose VC Delegate

extension AlertsViewController: AlertComposeViewControllerDelegate {
    func refreshData(completion: @escaping (() -> ())) {
        self.refreshAlerts {
            completion()
            self.refreshControl.endRefreshing()
        }
    }
}


// MARK: - Alert Table View Cell Delegate

extension AlertsViewController: AlertTableViewCellDelegate {
    func alertTableViewCell(replyToAlert alert: PFObject?) {
        if let alert = alert {
            let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
            let alertReplyNC = storyboard.instantiateViewController(withIdentifier: "AlertReplyNC") as! UINavigationController
            let alertReplyVC = alertReplyNC.viewControllers[0] as! AlertReplyViewController
            alertReplyVC.replyToAlert = alert
            alertReplyVC.delegate = self
            self.present(alertReplyNC, animated: true, completion: nil)
        }
    }
    
    func alertTableViewCell(updateFavedForAlert alert: PFObject?, atIndexPath indexPath: IndexPath, faved: Bool) {
        
        print("UPDATE FAVED", faved)
        
        if let alert = alert {
            AlertUtils.updateFaved(forAlert: alert, faved: faved) { (savedAlert: PFObject?, error: Error?) in
                if let error = error {
                    print("Error: \(error) \(error.localizedDescription)")
                } else if let updatedAlert = savedAlert {
                    
                    print("FAVE UPDATE COMPLETED FOR ALERT", updatedAlert)
                    
                    self.reloadAlert(alert: updatedAlert, atIndexPath: indexPath)
                }
            }
        }
    }
    
    func alertTableViewCell(updateFlaggedForAlert alert: PFObject?, atIndexPath indexPath: IndexPath, flagged: Bool) {
        
        print("UPDATE FLAGGED", flagged)
        
        if let alert = alert {
            AlertUtils.updateFlagged(forAlert: alert, flagged: flagged) { (savedAlert: PFObject?, error: Error?) in
                if let error = error {
                    self.presentFlaggedAlert(withError: true)
                    print("Error: \(error) \(error.localizedDescription)")
                } else if let updatedAlert = savedAlert {
                    if flagged {
                        self.presentFlaggedAlert(withError: false)
                    }
                    self.reloadAlert(alert: updatedAlert, atIndexPath: indexPath)
                }
            }
        } else {
            self.presentFlaggedAlert(withError: true)
        }
    }
}


// MARK: - Alert Update Helpers

extension AlertsViewController {
    fileprivate func reloadAlert(alert: PFObject, atIndexPath indexPath: IndexPath) {
        self.alerts[indexPath.row] = alert
        // Check that cell exists (i.e. we are not in the middle of an alerts refresh).
        if let _ = self.tableView.cellForRow(at: indexPath) as? AlertTableViewCell {
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


// MARK: - Alert Conversation VC Delegate

extension AlertsViewController: AlertConversationViewControllerDelegate {
    func alertConversationViewController(didUpdateAlert alert: PFObject) {
        self.reloadAlert(alert: alert, atIndexPath: self.selectedAlertIndexPath)
    }
}


// MARK: - Actions

extension AlertsViewController {
    func onRefresh() {
        self.refreshAlerts { 
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func toggleColorScheme(_ sender: Any) {
        self.blueMode = !self.blueMode
    }
}


// MARK: - Segue

extension AlertsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewAlertSegue" {
            let newAlertNC = segue.destination as! UINavigationController
            let newAlertVC = newAlertNC.viewControllers[0] as! NewAlertViewController
            newAlertVC.delegate = self
        }
    }
}
