//
//  CalendarViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/25/15.
//  Copyright (c) 2015 Mateo Garcia & Pat Boony. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class CalendarViewController: ContentViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noUpcomingEventsLabel: UILabel!
    
    var refreshControl: UIRefreshControl!
    
    var events: [PFObject] = [PFObject]()
    var currentIndex = 0
    let kPageLength = 10
    var currentReloadIndex = Int()
    
    // var firstCurrentEventCellIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenuButton(withColor: "red")
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 16.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(self.onRefresh), for: UIControlEvents.valueChanged)
        self.refreshControl.tintColor = UIColor.red
        self.refreshControl.attributedTitle = NSAttributedString(string: "Loading Past Events...", attributes: [NSForegroundColorAttributeName : UIColor.red])
        self.tableView.insertSubview(self.refreshControl, at: 0)
        
        self.currentReloadIndex = self.kPageLength / 2
        
        self.noUpcomingEventsLabel.isHidden = true
        
        self.refreshEvents(completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
}


// MARK: Table View

extension CalendarViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Two required components: DateTitleCell and SpaceCell.
        var numEventComponents = 2
        
        let event = events[section] as PFObject
        if let location = event["location"] as? String {
            numEventComponents += 1
        }
        if let description = event["description"] as? String {
            numEventComponents += 1
        }
        
        return numEventComponents
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events[indexPath.section] as PFObject
        
        var hasLocation = false
        if let location = event["location"] as? String {
            hasLocation = true
        }
        var hasDescription = false
        if let description = event["description"] as? String {
            hasDescription = true
        }
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateTitleCell", for: indexPath) as! DateTitleCell
            cell.setUpCell(event)
            return cell
        default:
            if indexPath.row == 1 && hasLocation {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
                cell.locationLabel.text = event["location"] as? String
                return cell
                
            } else if (indexPath.row == 1 && hasDescription) || (indexPath.row == 2 && hasDescription) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! DescriptionCell
                cell.descriptionLabel.text = event["description"] as? String
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCell", for: indexPath) as! SpaceCell
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


// MARK: - Refresh Helpers

extension CalendarViewController {
    func refreshEvents(completion: (() -> ())?) {
        self.getEvents { (events: [PFObject]) in
            DispatchQueue.main.async(execute: { 
                self.events = events
                self.tableView.contentOffset = CGPoint.zero
                self.tableView.reloadData()
                self.noUpcomingEventsLabel.isHidden = self.events.count != 0
            })
            completion?()
        }
    }
    
    func getEvents(completion: @escaping (([PFObject]) -> ())) {
        let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        currentHUD.label.text = "Loading Events..."
        
        let query = PFQuery(className: "Event")
        query.whereKey("startTime", greaterThan: Date())
        query.order(byAscending: "startTime")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            currentHUD.hide(animated: true)
            if let objects = objects {
                completion(objects)
            } else {
                print("object is nil")
                print(error!.localizedDescription)
            }
        }
    }
    
    func getPastEvents(before date: Date, count: Int, completion: @escaping (([PFObject]) -> ())) {
        let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        currentHUD.label.text = "Loading Events..."
        
        let query = PFQuery(className: "Event")
        query.whereKey("startTime", lessThan: date)
        query.order(byDescending: "startTime")
        query.limit = count
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            currentHUD.hide(animated: true)
            if let objects = objects {
                completion(objects.reversed())
            } else {
                print("object is nil")
                print(error?.localizedDescription)
            }
        }
    }
}


// New Event Delegate

extension CalendarViewController: NewEventViewControllerDelegate {
    func refreshCurrentEvents(completion: @escaping (() -> ())) {
        self.refreshEvents(completion: completion)
    }
}


// MARK: - Actions

extension CalendarViewController {
    func onRefresh() {
        var beforeDate: Date!
        if self.events.count > 0 {
            beforeDate = self.events[0]["startTime"] as! Date
        } else {
            beforeDate = Date()
        }
        self.getPastEvents(before: beforeDate, count: self.kPageLength) { (events: [PFObject]) in
            if events.count > 0 {
                DispatchQueue.main.async(execute: {
                    let previousContentOffset = self.tableView.contentOffset
                    let previousContentSize = self.tableView.contentSize
                    
                    self.events.insert(contentsOf: events, at: 0)
                    self.noUpcomingEventsLabel.isHidden = self.events.count != 0
                    self.tableView.insertSections(IndexSet(integersIn: NSRange(location: 0, length: events.count).toRange() ?? 0..<0), with: .fade)
                })
            }
        }
        self.refreshControl.endRefreshing()
    }
}


// MARK: - Navigation

extension CalendarViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewEventSegue" {
            let nc = segue.destination as! UINavigationController
            let newEventVC = nc.viewControllers[0] as! NewEventViewController
            newEventVC.delegate = self
        }
    }
}
