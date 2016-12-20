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
    var infoViewOriginalOrigin = CGPoint.zero
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
        self.searchController.searchBar.barStyle = .black
        
        self.definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.appDelegate.hamburgerViewController?.panGestureRecognizer.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.setContentOffset(CGPoint(x: 0, y: self.searchController.searchBar.frame.height - self.navigationController!.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height), animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.appDelegate.hamburgerViewController?.panGestureRecognizer.isEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Table View Delegate, Data Source

extension EditUsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "EditUserCell") as! EditUserTableViewCell
        cell.setupCell(user: self.usersToDisplay[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("DELETE CELL")
        self.deleteUser(self.usersToDisplay[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}


// MARK: - Helpers

extension EditUsersViewController {
    func fetchUsers() {
        let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        currentHUD.label.text = "Loading Users..."
        let query = PFUser.query()
        query!.order(byAscending: "username")
        query!.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.users = objects as! [PFUser]
                    self.usersToDisplay = self.users
                    
                    self.tableView.reloadData()
                    currentHUD.hide(animated: true)
                    // self.tableView.setContentOffset(CGPoint(x: 0, y: self.searchController.searchBar.frame.height - self.navigationController!.navigationBar.frame.height), animated: true)
                }
            }
        }
    }
    
    func deleteUser(_ user: PFUser) {
        var message = "Are you sure you want to delete "
        let username = user.object(forKey: "username") as? String
        if let username = username {
            message += username
        } else {
            message += "this user"
        }
        message += " from The Delt?"
        let alertVC = UIAlertController(title: "Delete User", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)
        if #available(iOS 9.0, *) {
            alertVC.preferredAction = cancelAction
        }
        alertVC.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction) in
            let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            if let username = username {
                currentHUD.label.text = "Deleting " + username + "..."
            } else {
                currentHUD.label.text = "Deleting User..."
            }
            user.deleteInBackground(block: { (deleted: Bool, error: Error?) in
                if error == nil && deleted {
                    currentHUD.hide(animated: true)
                } else {
                    let alertVC = UIAlertController(title: "Delete Failed", message: error?.localizedDescription, preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
                }
            })
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
}


// MARK: - Search Controller

extension EditUsersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.usersToDisplay = self.users
        if let searchText = searchController.searchBar.text {
            if searchText != "" {
                self.sortUsers(searchText)
            }
        }
        self.tableView.reloadData()
    }
    
    func sortUsers(_ searchText: String) {
        let text = searchText.lowercased()
        if self.usersToDisplay.count - 1 >= 0 {
            for i in (0 ..< self.usersToDisplay.count).reversed() {
                var shouldIncludeUser = false
                if var name = self.usersToDisplay[i]["name"] as? String {
                    name = name.lowercased()
                    shouldIncludeUser = name.range(of: text, options: [], range: nil, locale: nil) != nil
                }
                if var username = self.usersToDisplay[i]["username"] as? String {
                    username = username.lowercased()
                    shouldIncludeUser = username.range(of: text, options: [], range: nil, locale: nil) != nil
                }
                if !shouldIncludeUser {
                    self.usersToDisplay.remove(at: i)
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
