//
//  ReelScrollViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/19/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import MobileCoreServices
import Foundation
import Parse
import ParseUI

class ReelViewController: ContentViewController, UINavigationControllerDelegate {
    
    var photos = NSMutableArray()
    var uploadPhoto: UIImage?
    var uploadVideo: PFFile?
    var commentPhoto: NSMutableDictionary?
    
    var refreshControl: UIRefreshControl!
    
    let kHeaderWidth = 320
    let kHeaderHeight = 46
    let kProfileWidthHeight = 30
    
    @IBOutlet weak var tableView: UITableView!
    
    let transition = SwipeAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenuButton(withColor: "red")
        
        self.refreshData()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(ReelViewController.onRefresh), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl.tintColor = UIColor.redColor()
        self.tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Navigation Bar Style
        // self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.redColor()]

        /*
        var titleView = UILabel()
        titleView.backgroundColor = UIColor.redColor()
        titleView.textColor = UIColor.whiteColor()
        titleView.text = "REEL"
        self.navigationItem.titleView = titleView
        */
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Table View

extension ReelViewController: UITableViewDelegate, UITableViewDataSource {    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let photo = photos.objectAtIndex(section) as! NSMutableDictionary
        
        // Header.
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.kHeaderWidth, height: self.kHeaderHeight))
        headerView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        
        // Blur.
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = headerView.frame
        
        // Profile image.
        let profileImageView = ProfileImageView(frame: CGRect(x: 8 , y: 8, width: kProfileWidthHeight, height: kProfileWidthHeight))
        // profileImageView.backgroundColor = UIColor.redColor()
        profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
        profileImageView.layer.cornerRadius = 1
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = UIColor.redColor()
        profileImageView.profilePresenterDelegate = self
        
        let query = PFUser.query()
        query?.whereKey("username", equalTo: photo.valueForKey("username") as! String)
        query?.findObjectsInBackgroundWithBlock({ (users: [PFObject]?, error: NSError?) -> Void in
            if let users = users {
                let pfImageView = PFImageView()
                if users.count > 0 {
                    let user = users[0]
                    profileImageView.user = user as? PFUser
                    if let _ = user.valueForKey("photo"){
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
        
        // Username label.
        let usernameLabel = UsernameLabel(frame: CGRect(x: 8 + self.kProfileWidthHeight + 8, y: 12, width: 200, height: 16))
        let username = photo.valueForKey("username") as? String
        usernameLabel.username = username
        usernameLabel.text = username
        usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16.5)
        usernameLabel.textColor = UIColor.redColor()
        usernameLabel.sizeToFit()
        usernameLabel.profilePresenterDelegate = self
        
        /*
         USERNAME STYLE
         
         // Username Box
         var usernameBoxView = UIView(frame: CGRect(x: 8 + kProfileWidthHeight, y: 8, width: Int(usernameLabel.frame.width) + 16, height: kProfileWidthHeight))
         usernameBoxView.backgroundColor = UIColor.redColor()
         */
        
        headerView.insertSubview(profileImageView, atIndex: 0)
        headerView.insertSubview(usernameLabel, atIndex: 0)
        headerView.insertSubview(blurView, atIndex: 0)
        blurView.autoPinEdgesToSuperviewEdges()
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(self.kHeaderHeight)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let photo = self.photos.objectAtIndex(indexPath.section) as? NSMutableDictionary
        var commentOffset = 2
        var hasFaves = false
        if let numFaves = photo?.valueForKey("numFaves") as? Int {
            if numFaves > 0 {
                hasFaves = true
                commentOffset += 1
            }
        }
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("PhotoVideoCell", forIndexPath: indexPath) as! PhotoVideoCell
            
            cell.setUpCell(photo)
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("ButtonCell", forIndexPath: indexPath) as! ButtonCell
            
            cell.delegate = self
            cell.setUpCell(photo)
            return cell
        default:
            if indexPath.row == 2 && hasFaves {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("FavesCell", forIndexPath: indexPath) as! FavesCell
                
                cell.setUpCell(photo)
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
                cell.commentIndex = indexPath.row - commentOffset
                cell.usernameLabel.profilePresenterDelegate = self
                cell.setUpCell(photo)
                
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 2
        let photo = photos.objectAtIndex(section) as? NSMutableDictionary
        if let numFaves = photo?.valueForKey("numFaves") as? Int {
            if numFaves > 0 {
                numRows += 1
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
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? PhotoVideoCell {
            let photo = self.photos.objectAtIndex(indexPath.section) as! NSMutableDictionary
            if let _ = photo.valueForKey("videoFile") as? PFFile {
                cell.removeVideoPlayer()
            }
        }
    }
}


// MARK: - Button Cell Delegate

extension ReelViewController: ButtonCellDelegate {
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
                
                if let username = PFUser.currentUser()?.username {
                    // Increment or decrement fave count accordingly.
                    if faved {
                        photo.addObject(username, forKey: "favedBy")
                        photo.incrementKey("numFaves")
                    } else {
                        photo.removeObject(username, forKey: "favedBy")
                        photo.incrementKey("numFaves", byAmount: -1)
                    }
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
    
    func updateFlagged(photo: NSMutableDictionary?, flagged: Bool) {
        if flagged {
            let alert = UIAlertController(title: "Post Flagged", message: "Administrators will be notified and this post will be reviewed.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        let query = PFQuery(className: "Photo")
        let objectId = photo?.valueForKey("objectId") as! String
        query.getObjectInBackgroundWithId(objectId) {
            (photo: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let photo = photo {
                
                // Mark photo as flagged.
                photo["flagged"] = flagged
                
                print("PHOTO FLAGGED: \(photo["flagged"])")
                
                // Increment or decrement flag count accordingly.
                if flagged {
                    photo.incrementKey("numFlags")
                } else {
                    photo.incrementKey("numFlags", byAmount: -1)
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
}


// MARK: - Refresh

extension ReelViewController {
    
    // TODO: Just pass around PFObject, no need to deserialize...
    func refreshData() {
        let query = PFQuery(className: "Photo")
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
                        
                        // VIDEO
                        if let videoFile = object.objectForKey("videoFile") {
                            photo.setObject(videoFile, forKey: "videoFile")
                        }
                        
                        if let username = object.objectForKey("username") as? String {
                            photo.setObject(username, forKey: "username")
                        }
                        if let favedBy = object.objectForKey("favedBy") as? [String] {
                            photo.setObject(favedBy, forKey: "favedBy")
                        }
                        if let numFaves = object.objectForKey("numFaves") as? Int {
                            photo.setObject(numFaves, forKey: "numFaves")
                        }
                        if let flagged = object.objectForKey("flagged") as? Bool {
                            photo.setObject(flagged, forKey: "flagged")
                        }
                        if let numFlags = object.objectForKey("numFlags") as? Int {
                            photo.setObject(numFlags, forKey: "numFlags")
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
        self.refreshData()
        self.refreshControl.endRefreshing()
    }
}


// MARK: - Actions

extension ReelViewController {
    @IBAction func onAddButtonTapped(sender: AnyObject) {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.allowsEditing = true
        imagePickerVC.sourceType = .PhotoLibrary
        imagePickerVC.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        imagePickerVC.navigationBar.tintColor = UIColor.redColor()
        imagePickerVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: imagePickerVC, action: nil)
        self.presentViewController(imagePickerVC, animated: true, completion: nil)
    }
}


// MARK: - Image Picker Controller Delegate

extension ReelViewController: UIImagePickerControllerDelegate {
    // Triggered when the user finishes taking an image. Saves the chosen image to our temporary
    // uploadPhoto variable, and dismisses the image picker view controller. Once the image picker
    // view controller is dismissed (a.k.a. inside the completion handler) we modally segue to
    // show the "Location selection" screen. --Nick Troccoli
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Photo.
        if info[UIImagePickerControllerMediaType] as! String == kUTTypeImage as String {
            self.uploadPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
            
            // Video.
        } else {
            let videoUrl = info[UIImagePickerControllerMediaURL] as! NSURL
            let videoData = NSData(contentsOfURL: videoUrl)
            self.uploadVideo = PFFile(name: "video.mp4", data: videoData!)
            
            // Set video thumbnail image.
            let asset = AVAsset(URL: videoUrl)
            let generator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            let time = CMTimeMake(1, 1)
            let imageRef = try! generator.copyCGImageAtTime(time, actualTime: nil)
            self.uploadPhoto = UIImage(CGImage: imageRef)
        }
        
        let storyboard = UIStoryboard(name: "Reel", bundle: nil)
        let captionNC = storyboard.instantiateViewControllerWithIdentifier("CaptionNC") as! UINavigationController
        let captionVC = captionNC.viewControllers[0] as! CaptionViewController
        captionVC.delegate = self
        captionVC.photo = self.uploadPhoto!
        picker.pushViewController(captionVC, animated: true)
    }
}


// MARK: - Caption View Controller Delegate

extension ReelViewController: CaptionViewControllerDelegate {
    func captionViewController(didEnterCaption caption: String?) {
        let photo = PFObject(className: "Photo")
        
        let imageData = UIImageJPEGRepresentation(self.uploadPhoto!, 100)
        let imageFile = PFFile(name: "image.jpeg", data: imageData!)
        photo["imageFile"] = imageFile
        
        if let _ = self.uploadVideo {
            photo["videoFile"] = self.uploadVideo
        }
        
        photo["username"] = PFUser.currentUser()?.username
        photo["faved"] = false
        photo["numFaves"] = 0
        photo["flagged"] = false
        photo["numFlags"] = 0
        
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
}


// MARK: - Comment View Controller Delegate

extension ReelViewController: CommentViewControllerDelegate {
    func commentViewController(didEnterComment comment: String) {
        let query = PFQuery(className: "Photo")
        let objectId = commentPhoto?.valueForKey("objectId") as! String
        query.getObjectInBackgroundWithId(objectId) {
            (photo: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let photo = photo {
                var commentPair: [String]
                if let username = PFUser.currentUser()?.username {
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
}


// MARK: - Navigation

extension ReelViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addCommentSegue" {
            let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.viewControllers.first as! CommentViewController
            vc.delegate = self
            vc.photo = self.commentPhoto
        } else {
            let vc = segue.destinationViewController as! PhotoDetailsViewController
            let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            vc.selectedPhoto = self.photos[indexPath.section] as! NSMutableDictionary
        }
    }
}


// MARK: - Photo Video Cell Delegate

extension ReelViewController: PhotoVideoCellDelegate {
    func presentVideoDetailViewController(videoFile file: PFFile) {
        print("PRESENTING VIDEO DETAIL")
    }
}


// MARK: - Transition

extension ReelViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        /*
        if presented.isKindOfClass(PhotoDetailViewController) || presented.isKindOfClass(VideoDetailViewController) {
        self.transition.originFrame = self.transitioningCellFrame
        self.transition.presenting = true
        return self.transition
        }
        */
        
        return nil
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transition.presenting = false
        return self.transition
    }
}
