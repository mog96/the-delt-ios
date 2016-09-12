//
//  EditUsersViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/12/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse

class EditUsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tableViewPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var tableViewTapGestureRecognizer: UITapGestureRecognizer!
    
    var swipedCell: EditUserTableViewCell?
    var previousSwipedCell: EditUserTableViewCell?
    var infoViewOriginalOrigin = CGPointZero
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsMultipleSelectionDuringEditing = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Table View Delegate, Data Source

extension EditUsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("EditUserCell") as! EditUserTableViewCell
        cell.setupCell(user: PFUser.currentUser()!) // FIXME!
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        print("CAN EDIT")
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print("DELETE CELL")
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }
}

// MARK: - Actions

extension EditUsersViewController {
    @IBAction func onPanGesture(sender: AnyObject) {
        let location = sender.locationInView(self.tableView)
        let translation = sender.translationInView(self.tableView)
        let velocity = sender.velocityInView(self.tableView)
                
        if let indexPath = self.tableView.indexPathForRowAtPoint(location) {
            if sender.state == .Began {
                self.swipedCell = self.tableView.cellForRowAtIndexPath(indexPath) as? EditUserTableViewCell
                if self.previousSwipedCell == nil {
                    self.previousSwipedCell = self.swipedCell
                }
                
                if self.swipedCell == self.previousSwipedCell {
                    self.infoViewOriginalOrigin = self.previousSwipedCell!.infoView.frame.origin
                } else {
                    self.resetTableView()
                }
                
            } else if sender.state == .Changed {
                self.previousSwipedCell?.infoView.frame.origin.x = self.infoViewOriginalOrigin.x + translation.x
                
            } else if sender.state == .Ended {
                if velocity.x < 0 {
                    self.previousSwipedCell?.showDeleteButton()
                    self.tableView.scrollEnabled = false
                    self.tableViewTapGestureRecognizer.enabled = true
                } else {
                    self.resetTableView()
                }
            }
        }
    }
    
    @IBAction func onTableViewTapped(sender: AnyObject) {
        self.resetTableView()
    }
    
    func resetTableView() {
        self.previousSwipedCell?.hideDeleteButton()
        self.previousSwipedCell = nil
        self.tableView.scrollEnabled = true
        self.tableViewTapGestureRecognizer.enabled = false
    }
}


// MARK: - Edit User Cell Delegate

extension EditUsersViewController: EditUserTableViewCellDelegate {
    func deleteUser() {
        print("DELETE USER")
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
