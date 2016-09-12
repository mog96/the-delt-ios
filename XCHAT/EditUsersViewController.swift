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
    
    var swipedCell: EditUserTableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
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
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
}

// MARK: - Actions

extension EditUsersViewController {
    @IBAction func onPanGesture(sender: AnyObject) {
        let location = sender.locationInView(self.tableView)
        let translation = sender.translationInView(self.tableView)
        let velocity = sender.velocityInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)!
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! EditUserTableViewCell
        
        if sender.state == .Began {
            if self.swipedCell == nil {
                self.swipedCell = cell
            } else {
                if cell != self.swipedCell {
                    self.swipedCell.hideDeleteButton()
                }
            }
        } else if sender.state == .Changed {
            self.swipedCell.infoView.frame.origin.x = translation.x
            
        } else if sender.state == .Ended {
            
        }
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
