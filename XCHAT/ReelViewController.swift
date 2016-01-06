//
//  ReelScrollViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/19/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

// FIXME: Not too important, but could just use a [PFObject]() instead of serializing data
//        into NSMutableDictionary()

class ReelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CaptionViewControllerDelegate, CommentViewControllerDelegate, ButtonCellDelegate {
    
    var photos = NSMutableArray()
    var uploadPhoto: UIImage?
    var commentPhoto: NSMutableDictionary?
    
    var refreshControl: UIRefreshControl!
    
    let kHeaderWidth = 320
    let kHeaderHeight = 46
    let kProfileWidthHeight = 30
    
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Navigation Bar Style
        // self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.redColor()]

        /*
        var titleView = UILabel()
        titleView.backgroundColor = UIColor.redColor()
        titleView.textColor = UIColor.whiteColor()
        titleView.text = "REEL"
        self.navigationItem.titleView = titleView
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: TableView
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var photo = photos.objectAtIndex(section) as! NSMutableDictionary
        
        // Header
        var headerView = UIView(frame: CGRect(x: 0, y: 0, width: kHeaderWidth, height: kHeaderHeight))
        headerView.backgroundColor = UIColor(white: 3, alpha: 0.5)
        
        // Profile Image
        var profileImageView = UIImageView(frame: CGRect(x: 8 , y: 8, width: kProfileWidthHeight, height: kProfileWidthHeight))
        // profileImageView.backgroundColor = UIColor.redColor()
        profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
        profileImageView.layer.cornerRadius = 1
        profileImageView.clipsToBounds = true
        
        profileImageView.backgroundColor = UIColor.redColor()
        
        var query = PFUser.query()
        query?.whereKey("username", equalTo: photo.valueForKey("username") as! String)
        query?.findObjectsInBackgroundWithBlock({ (users: [PFObject]?, error: NSError?) -> Void in
            if let users = users {
                var pfImageView = PFImageView()
                if users.count > 0 {
                    if let _ = users[0].valueForKey("photo"){
                        pfImageView.file = users[0].valueForKey("photo") as? PFFile
                        pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                            if let error = error {
                                // Log details of the failure
                                print("Error: \(error) \(error.userInfo)")
                                
                            } else {
                                profileImageView.image = image
                            }
                        }
                    }

                }

            }
        })
        
        // Username Label
        var usernameLabel = UILabel(frame: CGRect(x: 8 + kProfileWidthHeight + 8, y: 12, width: 200, height: 16))
        usernameLabel.text = photo.valueForKey("username") as? String
        usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16.5)
        usernameLabel.textColor = UIColor.redColor()
        usernameLabel.sizeToFit()
        
        /*
        USERNAME STYLE

        // Username Box
        var usernameBoxView = UIView(frame: CGRect(x: 8 + kProfileWidthHeight, y: 8, width: Int(usernameLabel.frame.width) + 16, height: kProfileWidthHeight))
        usernameBoxView.backgroundColor = UIColor.redColor()
        */
        
        headerView.insertSubview(profileImageView, atIndex: 0)
        headerView.insertSubview(usernameLabel, atIndex: 0)
        // headerView.insertSubview(usernameBoxView, atIndex: 0)
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(self.kHeaderHeight)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var photo = photos.objectAtIndex(indexPath.section) as? NSMutableDictionary
        var commentOffset = 2
        var hasFaves = false
        if let numFaves = photo?.valueForKey("numFaves") as? Int {
            if numFaves > 0 {
                hasFaves = true
                commentOffset++
            }
        }
        switch indexPath.row {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
            
            cell.setUpCell(photo)
            return cell
        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier("ButtonCell", forIndexPath: indexPath) as! ButtonCell
            
            cell.delegate = self
            cell.setUpCell(photo)
            return cell
        default:
            if indexPath.row == 2 && hasFaves {
                
                var cell = tableView.dequeueReusableCellWithIdentifier("FavesCell", forIndexPath: indexPath) as! FavesCell
                
                cell.setUpCell(photo)
                return cell
            } else {
                var cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
            
                cell.commentIndex = indexPath.row - commentOffset
                cell.setUpCell(photo)
            
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 2
        var photo = photos.objectAtIndex(section) as? NSMutableDictionary
        if let numFaves = photo?.valueForKey("numFaves") as? Int {
            if numFaves > 0 {
                numRows++
            }
        }
        if let numComments = photo?.valueForKey("numComments") as? Int {
            numRows += numComments
        }
        return numRows
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return photos.count
    }
    
    
    // MARK: Actions
    
    @IBAction func onAddButtonTapped(sender: AnyObject) {
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = true
        imageVC.sourceType = .PhotoLibrary
        presentViewController(imageVC, animated: true, completion: nil)  // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
    
    
    // MARK: ImagePickerController
    
    // Triggered when the user finishes taking an image. Saves the chosen image to our temporary
    // uploadPhoto variable, and dismisses the image picker view controller. Once the image picker
    // view controller is dismissed (a.k.a. inside the completion handler) we modally segue to
    // show the "Location selection" screen. --Nick Troccoli
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        uploadPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
        dismissViewControllerAnimated(true, completion: { () -> Void in
            self.performSegueWithIdentifier("addCaptionSegue", sender: self) // segue to CaptionViewController
        })
    }
    
    
    // MARK: Protocol Implementations
    
    func captionViewController(didEnterCaption caption: String?) {
        let imageData = UIImageJPEGRepresentation(self.uploadPhoto!, 100)
        let imageFile = PFFile(name: "image.jpeg", data: imageData!)
        
        let photo = PFObject(className: "Photo")
        photo["imageFile"] = imageFile
        photo["username"] = PFUser.currentUser()?.username
        photo["faved"] = false
        photo["numFaves"] = 0
        
        var comments = [[String]]()
        if let caption = caption {
            photo["numComments"] = 1
            
            comments.append([PFUser.currentUser()!.username!, caption])
        } else {
            photo["numComments"] = 0
        }
        photo["comments"] = comments
        photo.saveInBackgroundWithBlock({ (completed: Bool, error: NSError?) -> Void in
            if let error = error {
                // Log details of the failure
                print("Error: \(error) \(error.userInfo)")
                
            } else {
                self.refreshData()
            }
        })
        
        if let numPhotosPosted = PFUser.currentUser()!.objectForKey("numPhotosPosted") as? Int {
            PFUser.currentUser()?.setObject(numPhotosPosted + 1, forKey: "numPhotosPosted")
        } else {
            PFUser.currentUser()?.setObject(1, forKey: "numPhotosPosted")
        }
        PFUser.currentUser()?.saveInBackground()
    }

    func commentViewController(didEnterComment comment: String) {
        let query = PFQuery(className: "Photo")
        let objectId = commentPhoto?.valueForKey("objectId") as! String
        query.getObjectInBackgroundWithId(objectId) {
            (photo: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let photo = photo {
                var commentPair: [String]
                if let username = PFUser.currentUser()!.username {
                    commentPair = [username, comment]
                } else {
                    commentPair = ["", comment]
                }
                
                photo.addObject(commentPair, forKey: "comments")   // Add comment
                photo.incrementKey("numComments")                  // Increment comment count
                
                photo.saveInBackgroundWithBlock({ (completed: Bool, eror: NSError?) -> Void in
                    if let error = error {
                        // Log details of the failure
                        print("Error: \(error) \(error.userInfo)")
                        
                    } else {
                        self.refreshData()
                    }
                })
            }
        }
    }
    
    func addComment(photo: NSMutableDictionary?) {
        commentPhoto = photo
        self.performSegueWithIdentifier("addCommentSegue", sender: self) // segue to CommentViewController
    }
    
    func updateFaved(photo: NSMutableDictionary?, didUpdateFaved faved: Bool) {
        let query = PFQuery(className: "Photo")
        let objectId = photo?.valueForKey("objectId") as! String
        query.getObjectInBackgroundWithId(objectId) {
            (photo: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let photo = photo {
                
                // Mark photo as faved.
                photo["faved"] = faved
                
                // Increment or decrement fave count accordingly.
                if faved {
                    photo.incrementKey("numFaves")
                } else {
                    photo.incrementKey("numFaves", byAmount: -1)
                }
                
                photo.saveInBackgroundWithBlock({ (completed: Bool, eror: NSError?) -> Void in
                    if let error = error {
                        // Log details of the failure
                        print("Error: \(error) \(error.userInfo)")
                        
                    } else {
                        self.refreshData() // FIXME: Makes for glitchy scrolling.
                    }
                })
            }
        }
    }
    
    
    // MARK: Refresh
    
    func refreshData() {
        let query = PFQuery(className:"Photo")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                // Log details of the failure
                print("Error: \(error) \(error.userInfo)")
                
            } else {
                print("Successfully retrieved \(objects!.count) photos.")
                
                if let objects = objects {
                    self.photos.removeAllObjects()
                    
                    print("Adding photos to array")
                    var i = 0
                    
                    for object in objects {
                        let photo = NSMutableDictionary()
                        photo.setObject(object.objectId!, forKey: "objectId")
                        
                        photo.setObject(object.objectForKey("imageFile")!, forKey: "imageFile")
                        
                        if let username = object.objectForKey("username") as? String {
                            photo.setObject(username, forKey: "username")
                        }
                        if let faved = object.objectForKey("faved") as? Bool {
                            photo.setObject(faved, forKey: "faved")
                        }
                        if let numFaves = object.objectForKey("numFaves") as? Int {
                            photo.setObject(numFaves, forKey: "numFaves")
                        }
                        if let numComments = object.objectForKey("numComments") as? Int {
                            photo.setObject(numComments, forKey: "numComments")
                        }
                        if let comments = object.objectForKey("comments") as? [[String]] {
                            photo.setObject(comments, forKey: "comments")
                        }
                        
                        print("\(i++)")
                        
                        self.photos.insertObject(photo, atIndex: 0)
                    }
                }
                
                self.tableView.reloadData()
                
                // FIXME: ADD ANIMATION FOR NEW PHOTO BEING ADDED
            }
        }
    }
    
    func onRefresh() {
        refreshData()
        refreshControl.endRefreshing()
    }
    
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addCaptionSegue" {
            let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.viewControllers.first as! CaptionViewController
            vc.delegate = self
            vc.photo = uploadPhoto!
        } else if segue.identifier == "addCommentSegue" {
            let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.viewControllers.first as! CommentViewController
            vc.delegate = self
            vc.photo = commentPhoto
        } else {
            let vc = segue.destinationViewController as! PhotoDetailsViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            vc.selectedPhoto = photos[indexPath.section] as! NSMutableDictionary
        }
    }
    
}
