//
//  NewThreadViewController.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/14/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class NewThreadViewController: UIViewController {
    
    
    @IBOutlet weak var threadTitleTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Do we need to load the session?
        print(PFUser.currentUser())
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getGroupId() -> Int? {
        let query = PFQuery(className: "thread")
        query.orderByDescending("groupId")
        query.limit = 1
        
        do {
            let object = try query.getFirstObject()
            return object["groupId"] as? Int
        } catch _ {
            return nil
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        print("CANCEL")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createThreadAction(sender: AnyObject) {
        print("CREATE THREAD")
        let newThread = PFObject(className: "thread")
        
        // Dummy
        newThread["groupId"] = 1
        newThread["threadName"] = threadTitleTextfield.text
        newThread.saveInBackgroundWithBlock { (result: Bool, error: NSError?) -> Void in
            if error != nil {
                print(error?.description)
            } else {
                print(result)
                self.threadTitleTextfield.text = nil
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
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
