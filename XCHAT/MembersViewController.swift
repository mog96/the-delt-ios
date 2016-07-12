//
//  MembersViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/26/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse


// FIXME:
// - search bar exit not animating properly
// - photos not displaying

// TODO
// - If USER's cell is tapped, go to profile edit view

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
    
    var hamburgerViewController: HamburgerViewController!
    
    var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenuButton(withColor: "white")
        
        screenSize = UIScreen.mainScreen().bounds
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBarFrame = CGRect(x: 16, y: 0, width: screenSize.width - 32, height: 44)
        searchBarHiddenFrame = CGRect(x: screenSize.width - 16, y: 0, width: 1, height: 44)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.navigationBar = self.navigationController?.navigationBar
        
        fetchUsers()
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil        
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersToDisplay.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemberCell", forIndexPath: indexPath) as! MemberCell
        
        let user = usersToDisplay[indexPath.row]
        let photo = photos[indexPath.row] as? UIImage
        cell.setUpCell(user, photo: photo)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.member = usersToDisplay[indexPath.row]
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let profileViewController = profileStoryboard.instantiateViewControllerWithIdentifier("EditableProfileViewController") as! EditableProfileViewController
        profileViewController.editable = false
        profileViewController.user = self.member
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    
    // MARK: Fetch
    
    // Stores users in [PFObject] and photos separately in NSMutableDictionary().
    func fetchUsers(){
        let query = PFUser.query()
        query!.orderByAscending("username")
        query!.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                self.users = objects as! [PFUser]
                self.usersToDisplay = self.users
                
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    // MARK: Actions
    
    @IBAction func onSearchButtonTapped(sender: AnyObject) {
        searchBar.frame = searchBarHiddenFrame
        self.navigationController?.navigationBar.addSubview(self.searchBar)
        self.leftBarButtonItemCopy = self.navigationItem.leftBarButtonItem
        self.rightBarButtonItemCopy = rightBarButtonItem
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
            self.searchBar.frame = self.searchBarFrame
        }) { (completed: Bool) -> Void in
            self.searchBar.becomeFirstResponder()
        }
        
    }
    
    
    // MARK: Search Bar
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        usersToDisplay = self.users
        if searchText != "" {
            sortUsers(searchText)
        }
        tableView.reloadData()
    }
    
    func sortUsers(searchText: String) {
        let text = searchText.lowercaseString
        for var i = self.usersToDisplay.count - 1; i >= 0; i-- {
            var shouldIncludeUser = false
            if var name = usersToDisplay[i]["name"] as? String {
                name = name.lowercaseString
                shouldIncludeUser = name.rangeOfString(text, options: [], range: nil, locale: nil) != nil
            }
            if var username = usersToDisplay[i]["username"] as? String {
                username = username.lowercaseString
                shouldIncludeUser = username.rangeOfString(text, options: [], range: nil, locale: nil) != nil
            }
            if !shouldIncludeUser {
                usersToDisplay.removeAtIndex(i)
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        
        UIView.transitionWithView(self.searchBar, duration: 0.2, options: .TransitionCrossDissolve, animations: { () -> Void in
            //
            }) { _ in
                self.navigationItem.setRightBarButtonItem(self.rightBarButtonItemCopy, animated: true)
                self.navigationItem.setLeftBarButtonItem(self.leftBarButtonItemCopy, animated: true)
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
