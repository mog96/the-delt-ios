//
//  CalendarViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/25/15.
//  Copyright (c) 2015 Mateo Garcia & Pat Boony. All rights reserved.
//

import UIKit

// TODO:
// - SET EVENT COLOR FOR DAY OF WEEK

class CalendarViewController: ContentViewController, UITableViewDelegate, UITableViewDataSource {
    
    var events: [PFObject] = [PFObject]()
    var refreshControl: UIRefreshControl!
    
    // @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenuButton(withColor: "red")
        
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.estimatedRowHeight = 16.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        refreshData()
        
        /*
        DEFAULT (no events, tap '+' to add) VIEW
        if events.count == 0 {
        defaultView.hidden = false
        print(defaultView.hidden)
        print("SHOW DEFAULT")
        }
        */
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshData()
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
        var query = PFQuery(className: "Event")
        query.whereKey("startTime", greaterThan: NSDate())
        query.orderByAscending("startTime")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                self.events = objects
                self.tableView.reloadData()
            } else {
                print("object is nil")
                print(error?.description)
            }
        }
    }
    
    func onRefresh() {
        refreshData()
        refreshControl.endRefreshing()
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

