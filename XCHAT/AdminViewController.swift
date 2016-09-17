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
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 2
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = NSBundle.mainBundle().loadNibNamed("SettingsHeaderView", owner: self, options: nil)![0] as! SettingsHeaderView
        switch section {
        case 1:
            headerView.headerLabel.text = "ACTIONS"
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
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                let cell = NSBundle.mainBundle().loadNibNamed("SettingsDescriptionTableViewCell", owner: self, options: nil)![0] as! SettingsDescriptionTableViewCell
                cell.setDescription("Immediately notify all delts with an important message.")
                return cell
            default:
                let cell = NSBundle.mainBundle().loadNibNamed("ActionButtonTableViewCell", owner: self, options: nil)![0] as! ActionButtonTableViewCell
                cell.delegate = self
                cell.actionButton.setTitle("Alert All Delts", forState: .Normal)
                return cell
            }
            
        default:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("EditUsersCell")!
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }
}


// MARK: - Action Button Delegate

extension AdminViewController: ActionButtonCellDelegate {
    func actionButtonCell(tappedBySender sender: AnyObject) {
        let alertVC = UIAlertController(title: "Alert All Delts", message: "All Delts will be notified immediately.", preferredStyle: .Alert)
        alertVC.addTextFieldWithConfigurationHandler { (textField: UITextField) in
            textField.placeholder = "Add a message."
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertVC.addAction(UIAlertAction(title: "Send", style: .Default, handler: { (action: UIAlertAction) in
            let text = alertVC.textFields![0].text
            print("ALERT ALL DELTS:", text)
        }))
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
}
