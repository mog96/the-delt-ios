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
    
    var refreshControl = UIRefreshControl()
    
    var alerts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenuButton(withColor: "white")
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 16.0
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


// MARK: - Helpers

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
        query.order(byDescending: "updatedAt")
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
        // cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let replyToUser = self.alerts[indexPath.row]["author"] as? PFUser {
            let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
            let alertReplyNC = storyboard.instantiateViewController(withIdentifier: "AlertReplyNC") as! UINavigationController
            let alertReplyVC = alertReplyNC.viewControllers[0] as! AlertReplyViewController
            alertReplyVC.replyToUser = replyToUser
            self.navigationController?.pushViewController(alertReplyVC, animated: true)
        }
    }
}


// MARK: - New Alert VC Delegate

extension AlertsViewController: NewAlertViewControllerDelegate {
    func refreshData(completion: @escaping (() -> ())) {
        self.refreshAlerts {
            completion()
            self.refreshControl.endRefreshing()
        }
    }
}


// MARK: - Actions

extension AlertsViewController {
    func onRefresh() {
        self.refreshAlerts { 
            self.refreshControl.endRefreshing()
        }
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
