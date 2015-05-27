//
//  ThreadsViewController.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/13/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit

class ThreadsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var threadsTableView: UITableView!
    
    var threads: [PFObject] = [PFObject]()
    
    func loginDummyUser() {
        PFUser.logInWithUsernameInBackground("patboony", password: "123456") { (user: PFUser?, error: NSError?) -> Void in
            if error != nil {
                println(error?.description)
            } else {
                // Done
                println(user)
                self.fetchThreads()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Login to Parse
        loginDummyUser()
        
        threadsTableView.delegate = self
        threadsTableView.dataSource = self
        
        // Fetch threads and display in the table
        //fetchThreads()
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchThreads()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchThreads() {
        var query = PFQuery(className: "thread")
        query.orderByDescending("updatedAt")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if objects != nil {
                //println(objects)
                self.threads = (objects as! [PFObject]?)!
                self.threadsTableView.reloadData()
            } else {
                println("object is nil")
                println(error?.description)
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ThreadTableViewCell", forIndexPath: indexPath) as! ThreadTableViewCell
        
        let threadForRow = threads[indexPath.row] as PFObject
        cell.threadNameLabel.text = threadForRow["threadName"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "readThreadSegue" {
            let senderCell = sender as! UITableViewCell
            let messageVC = segue.destinationViewController as! MessageViewController
            let senderIndexPath = threadsTableView.indexPathForCell(senderCell)
            
            // Tell MessageViewController the objectId of the thread to load
            let threadForRow = threads[senderIndexPath!.row] as PFObject
            messageVC.threadId = threadForRow.objectId!
        }
        
    }
    
    
}
