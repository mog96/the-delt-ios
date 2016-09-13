//
//  EditUsersViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/12/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import MBProgressHUD
import Parse

class EditUsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    
    var swipedCell: EditUserTableViewCell?
    var previousSwipedCell: EditUserTableViewCell?
    var infoViewOriginalOrigin = CGPointZero
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var users = [PFUser]()
    var usersToDisplay = [PFUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.backgroundView = UIView()
        
        self.fetchUsers()
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.barStyle = .Black
        
        self.definesPresentationContext = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.appDelegate.hamburgerViewController.panGestureRecognizer.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.setContentOffset(CGPoint(x: 0, y: self.searchController.searchBar.frame.height - self.navigationController!.navigationBar.frame.height - UIApplication.sharedApplication().statusBarFrame.height), animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.appDelegate.hamburgerViewController.panGestureRecognizer.enabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Table View Delegate, Data Source

extension EditUsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersToDisplay.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("EditUserCell") as! EditUserTableViewCell
        cell.setupCell(user: self.usersToDisplay[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print("DELETE CELL")
        self.deleteUser(self.usersToDisplay[indexPath.row])
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }
}


// MARK: - Helpers

extension EditUsersViewController {
    func fetchUsers() {
        let currentHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        currentHUD.label.text = "Loading Users..."
        let query = PFUser.query()
        query!.orderByAscending("username")
        query!.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.users = objects as! [PFUser]
                    self.usersToDisplay = self.users
                    
                    self.tableView.reloadData()
                    currentHUD.hideAnimated(true)
                    // self.tableView.setContentOffset(CGPoint(x: 0, y: self.searchController.searchBar.frame.height - self.navigationController!.navigationBar.frame.height), animated: true)
                }
            }
        }
    }
    
    func deleteUser(user: PFUser) {
        var message = "Are you sure you want to delete "
        let username = user.objectForKey("username") as? String
        if let username = username {
            message += username
        } else {
            message += "this user"
        }
        message += " from The Delt?"
        let alertVC = UIAlertController(title: "Delete User", message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertVC.addAction(cancelAction)
        if #available(iOS 9.0, *) {
            alertVC.preferredAction = cancelAction
        }
        alertVC.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action: UIAlertAction) in
            let currentHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            if let username = username {
                currentHUD.label.text = "Deleting " + username + "..."
            } else {
                currentHUD.label.text = "Deleting User..."
            }
            user.deleteInBackgroundWithBlock({ (deleted: Bool, error: NSError?) in
                if error == nil && deleted {
                    currentHUD.hideAnimated(true)
                } else {
                    let alertVC = UIAlertController(title: "Delete Failed", message: error?.userInfo["error"] as? String, preferredStyle: .Alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertVC, animated: true, completion: nil)
                }
            })
        }))
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
}


// MARK: - Search Controller

extension EditUsersViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.usersToDisplay = self.users
        if let searchText = searchController.searchBar.text {
            if searchText != "" {
                self.sortUsers(searchText)
            }
        }
        self.tableView.reloadData()
    }
    
    func sortUsers(searchText: String) {
        let text = searchText.lowercaseString
        if self.usersToDisplay.count - 1 >= 0 {
            for i in (0 ..< self.usersToDisplay.count).reverse() {
                var shouldIncludeUser = false
                if var name = self.usersToDisplay[i]["name"] as? String {
                    name = name.lowercaseString
                    shouldIncludeUser = name.rangeOfString(text, options: [], range: nil, locale: nil) != nil
                }
                if var username = self.usersToDisplay[i]["username"] as? String {
                    username = username.lowercaseString
                    shouldIncludeUser = username.rangeOfString(text, options: [], range: nil, locale: nil) != nil
                }
                if !shouldIncludeUser {
                    self.usersToDisplay.removeAtIndex(i)
                }
            }
        }
    }
}


/*
// MARK: - Navigation

extension EditUsersViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // USER PROFILE VIEW
    }
}
*/
