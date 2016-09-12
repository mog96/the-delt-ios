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
    
    var swipedCell: EditUserTableViewCell?
    var previousSwipedCell: EditUserTableViewCell?
    var infoViewOriginalOrigin = CGPointZero
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    override func viewWillAppear(animated: Bool) {
        self.appDelegate.hamburgerViewController.panGestureRecognizer.enabled = false
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
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("EditUserCell") as! EditUserTableViewCell
        cell.setupCell(user: PFUser.currentUser()!) // FIXME!
        return cell
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


/*
// MARK: - Navigation

extension EditUsersViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // USER PROFILE VIEW
    }
}
*/
