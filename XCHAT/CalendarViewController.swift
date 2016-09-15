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
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 16.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(self.onRefresh), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl.tintColor = UIColor.redColor()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Loading Past Events...", attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
        self.tableView.insertSubview(refreshControl, atIndex: 0)
        
        self.currentReloadIndex = self.kPageLength / 2
        
        self.noUpcomingEventsLabel.hidden = true
        
        self.getEvents { (events: [PFObject]) in
            self.events = events
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
}


// MARK: Table View

extension CalendarViewController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
            let cell = tableView.dequeueReusableCellWithIdentifier("DateTitleCell", forIndexPath: indexPath) as! DateTitleCell
            cell.setUpCell(event)
            return cell
        default:
            if indexPath.row == 1 && hasLocation {
                let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell
                cell.locationLabel.text = event["location"] as? String
                return cell
                
            } else if (indexPath.row == 1 && hasDescription) || (indexPath.row == 2 && hasDescription) {
                let cell = tableView.dequeueReusableCellWithIdentifier("DescriptionCell", forIndexPath: indexPath) as! DescriptionCell
                cell.descriptionLabel.text = event["description"] as? String
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("SpaceCell", forIndexPath: indexPath) as! SpaceCell
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}


// MARK: - Refresh Helpers

extension CalendarViewController {
    func getEvents(completion completion: ([PFObject] -> ())) {
        let currentHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        currentHUD.label.text = "Loading Events..."
        
        let query = PFQuery(className: "Event")
        query.whereKey("startTime", greaterThan: NSDate())
        query.orderByAscending("startTime")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            currentHUD.hideAnimated(true)
            if let objects = objects {
                completion(objects)
            } else {
                print("object is nil")
                print(error?.description)
            }
        }
    }
    
    func getPastEvents(before date: NSDate, count: Int, completion: ([PFObject] -> ())) {
        let currentHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        currentHUD.label.text = "Loading Events..."
        
        let query = PFQuery(className: "Event")
        query.whereKey("startTime", lessThan: date)
        query.orderByDescending("startTime")
        query.limit = count
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            currentHUD.hideAnimated(true)
            if let objects = objects {
                completion(objects.reverse())
            } else {
                print("object is nil")
                print(error?.description)
            }
        }
    }
}


// New Event Delegate

extension CalendarViewController: NewEventViewControllerDelegate {
    func refreshCurrentEvents() {
        self.getEvents { (events: [PFObject]) in
            self.events = events
            self.tableView.reloadData()
        }
    }
}


// MARK: - Actions

extension CalendarViewController {
    func onRefresh() {
        self.getPastEvents(before: self.events[0]["startTime"] as! NSDate, count: self.kPageLength) { (events: [PFObject]) in
            if events.count > 0 {
                let previousContentOffset = self.tableView.contentOffset
                let previousContentSize = self.tableView.contentSize
                self.events.insertContentsOf(events, at: 0)
                self.tableView.insertSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: events.count)), withRowAnimation: .None)
                let firstCurrentEventCellIndexPath = NSIndexPath(forRow: 0, inSection: events.count)
                let rect = self.tableView.rectForSection(firstCurrentEventCellIndexPath.section)
                let navBarBottomY = self.navigationController!.navigationBar.frame.origin.y + self.navigationController!.navigationBar.frame.height
                let bottomYInset = UIScreen.mainScreen().bounds.height - (navBarBottomY + rect.height)
                
                // Adjust inset and offset so that first current event cell sits at top of table view.
                if previousContentSize.height < self.tableView.frame.height {
                    
                }
                // self.tableView.contentInset = UIEdgeInsets(top: navBarBottomY, left: 0, bottom: bottomYInset, right: 0)
                self.tableView.setContentOffset(CGPoint(x: 0, y: rect.origin.y - navBarBottomY), animated: false)
            }
        }
        self.refreshControl.endRefreshing()
    }
}


// MARK: - Navigation

extension CalendarViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewEventSegue" {
            let nc = segue.destinationViewController as! UINavigationController
            let newEventVC = nc.viewControllers[0] as! NewEventViewController
            newEventVC.delegate = self
        }
    }
}
