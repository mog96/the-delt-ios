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

// TODO:
// - SET EVENT COLOR FOR DAY OF WEEK (alternate rainbow colors)

class CalendarViewController: ContentViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noUpcomingEventsLabel: UILabel!
    
    var refreshControl: UIRefreshControl!
    
    var events: [PFObject] = [PFObject]()
    var currentIndex = 0
    let kPageLength = 6
    var currentReloadIndex = Int()
    
    var firstCurrentEventCellIndexPath: NSIndexPath?
    
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
        self.tableView.insertSubview(refreshControl, atIndex: 0)
        
        self.currentReloadIndex = self.kPageLength / 2
        
        self.noUpcomingEventsLabel.hidden = true
        
        self.getEvents(index: self.currentIndex, count: self.kPageLength) { (events: [PFObject]) in
            self.events = events
            if let index = self.events.indexOf({ (event: PFObject) -> Bool in
                return (event["startTime"] as! NSDate).compare(NSDate()) == .OrderedDescending
            }) {
                self.firstCurrentEventCellIndexPath = NSIndexPath(forRow: 0, inSection: index)
            }
            self.tableView.reloadData()
            
            // Set table view offset.
            let navBarBottomY = self.navigationController!.navigationBar.frame.origin.y + self.navigationController!.navigationBar.frame.height
            if let indexPath = self.firstCurrentEventCellIndexPath {
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
                let rect = self.tableView.rectForSection(indexPath.section)
                let bottomYInset = UIScreen.mainScreen().bounds.height - (navBarBottomY + rect.height)
                self.tableView.contentInset = UIEdgeInsets(top: navBarBottomY, left: 0, bottom: bottomYInset, right: 0)
                self.tableView.setContentOffset(CGPoint(x: 0, y: rect.origin.y - navBarBottomY), animated: false)
                
            } else { // No current events.
                let bottomYInset = UIScreen.mainScreen().bounds.height - navBarBottomY
                self.tableView.contentInset = UIEdgeInsetsMake(navBarBottomY, 0, bottomYInset, 0)
                self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height), animated: false)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Two required components: DateTitleCell and SpaceCell.
        var numEventComponents = 2
        
        var event = events[section] as PFObject
        if let location = event["location"] as? String {
            numEventComponents++
        }
        if let description = event["description"] as? String {
            numEventComponents++
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
            var cell = tableView.dequeueReusableCellWithIdentifier("DateTitleCell", forIndexPath: indexPath) as! DateTitleCell
            cell.setUpCell(event)
            return cell
        default:
            if indexPath.row == 1 && hasLocation {
                var cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell
                cell.locationLabel.text = event["location"] as? String
                return cell
                
            } else if (indexPath.row == 1 && hasDescription) || (indexPath.row == 2 && hasDescription) {
                var cell = tableView.dequeueReusableCellWithIdentifier("DescriptionCell", forIndexPath: indexPath) as! DescriptionCell
                cell.descriptionLabel.text = event["description"] as? String
                return cell
                
            } else {
                var cell = tableView.dequeueReusableCellWithIdentifier("SpaceCell", forIndexPath: indexPath) as! SpaceCell
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    // MARK: Refresh
    
    func refreshData() {
        print("CALENDAR REFRESH DATA") // START HERE
    }
    
    func getEvents(index index: Int, count: Int, completion: ([PFObject] -> ())) {
        let currentHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        currentHUD.label.text = "Loading Events..."
        
        let query = PFQuery(className: "Event")
        // query.whereKey("startTime", greaterThan: NSDate())
        query.orderByDescending("startTime")
        query.limit = 10
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
    
    func onRefresh() {
        // refreshData() // FIXME
        refreshControl.endRefreshing()
    }
}

