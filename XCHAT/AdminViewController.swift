//
//  AdminViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/9/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class AdminViewController: ContentViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenuButton(withColor: "white")
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


// MARK: - Table View Delegate, Data Source

extension AdminViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = NSBundle.mainBundle().loadNibNamed("SettingsHeaderView", owner: self, options: nil)![0] as! SettingsHeaderView
        switch section {
        default:
            headerView.headerLabel.text = "MANAGE USERS"
        }
        headerView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, headerView.frame.height)
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("EditUsersCell")!
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }
}
