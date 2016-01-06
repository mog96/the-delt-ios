//
//  MembersViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/26/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit


// FIXME:
// - search bar exit not animating properly
// - photos not displaying

// TODO
// - If USER's cell is tapped, go to profile edit view

class MembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var users = [PFUser]()
    var usersToDisplay = [PFUser]()
    var photos = NSMutableDictionary()
    
    var screenSize: CGRect!
    var searchBar = UISearchBar()
    var searchBarFrame: CGRect!
    var searchBarHiddenFrame: CGRect!
    
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    var rightBarButtonItemCopy: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!
    
    var member: PFUser!
    
    var hamburgerViewController: HamburgerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        fetchUsers()
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.hamburgerViewController.panGestureRecognizer.enabled = true
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
        self.performSegueWithIdentifier("detailSegue", sender: self)
    }
    
    
    // MARK: Fetch
    
    // Stores users in [PFObject] and photos separately in NSMutableDictionary().
    func fetchUsers(){
        let query = PFUser.query()
        query!.orderByAscending("name")
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
        rightBarButtonItemCopy = rightBarButtonItem
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.navigationItem.rightBarButtonItem = nil
            self.searchBar.frame = self.searchBarFrame
        }) { (completed: Bool) -> Void in
            self.searchBar.becomeFirstResponder()
        }
        
    }
    
    
    // MARK: Search Bar
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        usersToDisplay = users
        if searchText != "" {
            sortUsers(searchText)
        }
        tableView.reloadData()
    }
    
    func sortUsers(searchText: String) {
        let text = searchText.lowercaseString
        for var i = usersToDisplay.count - 1; i >= 0; i-- {
            var name = usersToDisplay[i]["name"] as! String
            name = name.lowercaseString
            if name.rangeOfString(text, options: [], range: nil, locale: nil) == nil {
                usersToDisplay.removeAtIndex(i)
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        
        UIView.animateWithDuration(0.9, animations: { () -> Void in
            self.searchBar.frame = self.searchBarHiddenFrame
        }) { (completed: Bool) -> Void in
            self.navigationItem.setRightBarButtonItem(self.rightBarButtonItemCopy, animated: true)
            self.searchBar.removeFromSuperview()
            
            self.usersToDisplay = self.users
            self.tableView.reloadData()
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.hamburgerViewController.panGestureRecognizer.enabled = false
        
        let profileViewController = segue.destinationViewController as! EditableProfileViewController
        profileViewController.editable = false
        profileViewController.user = self.member
    }

}
