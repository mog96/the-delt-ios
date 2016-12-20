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
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("SettingsHeaderView", owner: self, options: nil)![0] as! SettingsHeaderView
        switch section {
        case 1:
            headerView.headerLabel.text = "ACTIONS"
        default:
            headerView.headerLabel.text = "MANAGE USERS"
        }
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerView.frame.height)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                let cell = Bundle.main.loadNibNamed("SettingsDescriptionTableViewCell", owner: self, options: nil)![0] as! SettingsDescriptionTableViewCell
                cell.setDescription("Immediately notify all delts with an important message.")
                return cell
            default:
                let cell = Bundle.main.loadNibNamed("ActionButtonTableViewCell", owner: self, options: nil)![0] as! ActionButtonTableViewCell
                cell.delegate = self
                cell.actionButton.setTitle("Alert All Delts", for: UIControlState())
                return cell
            }
        default:
            switch indexPath.row {
            case 0:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "ApproveSignupRequestsCell")!
                return cell
            default:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "EditUsersCell")!
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}


// MARK: - Action Button Delegate

extension AdminViewController: ActionButtonCellDelegate {
    func actionButtonCell(tappedBySender sender: AnyObject) {
        let alertVC = UIAlertController(title: "Alert All Delts", message: "All Delts will be notified immediately.", preferredStyle: .alert)
        alertVC.addTextField { (textField: UITextField) in
            textField.placeholder = "Add a message."
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertVC.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action: UIAlertAction) in
            let text = alertVC.textFields![0].text
            print("ALERT ALL DELTS:", text)
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
}
