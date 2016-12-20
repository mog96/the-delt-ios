//
//  MembersViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/26/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse

class MembersViewController: ContentViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var users = [PFUser]()
    var usersToDisplay = [PFUser]()
    var photos = NSMutableDictionary()
    
    var screenSize: CGRect!
    var searchBar = UISearchBar()
    var searchBarFrame: CGRect!
    var searchBarHiddenFrame: CGRect!
    
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    var leftBarButtonItemCopy: UIBarButtonItem!
    var rightBarButtonItemCopy: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!
    
    var member: PFUser!
    var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenuButton(withColor: "white")
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        
        screenSize = UIScreen.main.bounds
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBarFrame = CGRect(x: 16, y: 0, width: screenSize.width - 32, height: 44)
        searchBarHiddenFrame = CGRect(x: screenSize.width - 16, y: 0, width: 1, height: 44)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.navigationBar = self.navigationController?.navigationBar
        
        self.fetchUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
        
        let user = usersToDisplay[indexPath.row]
        let photo = photos[indexPath.row] as? UIImage
        cell.setUpCell(user, photo: photo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.member = usersToDisplay[indexPath.row]
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let profileViewController = profileStoryboard.instantiateViewController(withIdentifier: "EditableProfileViewController") as! EditableProfileViewController
        profileViewController.editable = false
        profileViewController.user = self.member
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    
    // MARK: Fetch
    
    // Stores users in [PFObject] and photos separately in NSMutableDictionary().
    func fetchUsers() {
        let query = PFUser.query()
        query!.order(byAscending: "username")
        query!.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if let objects = objects {
                self.users = objects as! [PFUser]
                self.usersToDisplay = self.users
                
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func onSearchButtonTapped(_ sender: AnyObject) {
        searchBar.frame = searchBarHiddenFrame
        self.navigationController?.navigationBar.addSubview(self.searchBar)
        self.leftBarButtonItemCopy = self.navigationItem.leftBarButtonItem
        self.rightBarButtonItemCopy = rightBarButtonItem
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
            self.searchBar.frame = self.searchBarFrame
        }, completion: { (completed: Bool) -> Void in
            self.searchBar.becomeFirstResponder()
        }) 
        
    }
    
    
    // MARK: Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        usersToDisplay = self.users
        if searchText != "" {
            sortUsers(searchText)
        }
        tableView.reloadData()
    }
    
    func sortUsers(_ searchText: String) {
        let text = searchText.lowercased()
        for i in stride(from: self.usersToDisplay.count - 1, to: 0, by: -1) {
            var shouldIncludeUser = false
            if var name = usersToDisplay[i]["name"] as? String {
                name = name.lowercased()
                shouldIncludeUser = name.range(of: text, options: [], range: nil, locale: nil) != nil
            }
            if var username = usersToDisplay[i]["username"] as? String {
                username = username.lowercased()
                shouldIncludeUser = username.range(of: text, options: [], range: nil, locale: nil) != nil
            }
            if !shouldIncludeUser {
                usersToDisplay.remove(at: i)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        
        UIView.transition(with: self.searchBar, duration: 0.2, options: .transitionCrossDissolve, animations: { () -> Void in
            //
            }) { _ in
                self.navigationItem.setRightBarButton(self.rightBarButtonItemCopy, animated: true)
                self.navigationItem.setLeftBarButton(self.leftBarButtonItemCopy, animated: true)
                self.searchBar.removeFromSuperview()
                
                self.usersToDisplay = self.users
                self.tableView.reloadData()
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.hamburgerViewController.panGestureRecognizer.enabled = false
        
        let profileViewController = segue.destinationViewController as! EditableProfileViewController
        profileViewController.editable = false
        profileViewController.user = self.member
    }
    */

}
