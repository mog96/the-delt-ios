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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deltLoadingView: DeltLoadingView!
    
    var photos = NSMutableArray()
    var uploadPhoto: UIImage?
    var uploadVideo: PFFile?
    var commentPhoto: NSMutableDictionary?
    
    var refreshControl: UIRefreshControl?
    var chooseMediaAlertController: UIAlertController!
    
    let kHeaderWidth = 320
    let kHeaderHeight = 46
    let kProfileWidthHeight = 30
    
    let transition = SwipeAnimator()
    
    let kWelcomeMessageKey = "ReelRefreshControlWelcomeMessageDisplayed"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        self.setMenuButton(withColor: "red")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Navigation Bar Style
        // self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.redColor()]

        /*
        var titleView = UILabel()
        titleView.backgroundColor = UIColor.redColor()
        titleView.textColor = UIColor.whiteColor()
        titleView.text = "REEL"
        self.navigationItem.titleView = titleView
        */
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(self.onRefresh), for: UIControlEvents.valueChanged)
        self.refreshControl!.tintColor = UIColor.red
        if UserDefaults.standard.object(forKey: self.kWelcomeMessageKey) == nil || UserDefaults.standard.object(forKey: self.kWelcomeMessageKey) as? Bool == false {
            self.refreshControl!.attributedTitle = NSAttributedString(string: "Welcome to The Delt. It's a little slow...", attributes: [NSForegroundColorAttributeName : UIColor.red])
            UserDefaults.standard.set(true, forKey: self.kWelcomeMessageKey)
        }
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = self.refreshControl
        } else {
            self.tableView.insertSubview(self.refreshControl!, at: 0)
        }
        
        self.deltLoadingView.deltColor = UIColor.red
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.firstLoad()
        
        self.chooseMediaAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        self.chooseMediaAlertController.addAction(UIAlertAction(title: "CLICK", style: .destructive, handler: { _ in      // FIXME: Using .Destructive to get red text color is a little hacky...
            self.presentImagePicker(usingPhotoLibrary: false)
        }))
        self.chooseMediaAlertController.addAction(UIAlertAction(title: "CHOOSE", style: .destructive, handler: { _ in
            self.presentImagePicker(usingPhotoLibrary: true)
        }))
        self.chooseMediaAlertController.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { _ in
            self.chooseMediaAlertController.dismiss(animated: true, completion: nil)
        }))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults(suiteName: "group.com.tdx.thedelt")?.object(forKey: "DidSetPushNotifications") == nil {
            let alert = UIAlertController(title: "Welcome", message: "You're about to be asked to enable push notifications for the delt. We use these for alerts, chats, and calendar events.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                AppDelegate.registerForPushNotifications(UIApplication.shared)
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Helpers

extension ReelViewController {
    func presentImagePicker(usingPhotoLibrary photoLibrary: Bool) {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.allowsEditing = true
        imagePickerVC.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        if photoLibrary {
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.navigationBar.tintColor = UIColor.red
            imagePickerVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: imagePickerVC, action: nil)
        } else {
            imagePickerVC.sourceType = .camera
        }
        self.present(imagePickerVC, animated: true, completion: nil)
    }
}


// MARK: - Table View

extension ReelViewController: UITableViewDelegate, UITableViewDataSource {    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Header.
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.kHeaderWidth, height: self.kHeaderHeight))
        headerView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        
        // Blur.
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.frame = headerView.frame
        
        // Profile image.
        let profileImageView = ProfileImageView(frame: CGRect(x: 8 , y: 8, width: kProfileWidthHeight, height: kProfileWidthHeight))
        // profileImageView.backgroundColor = UIColor.redColor()
        profileImageView.contentMode = UIViewContentMode.scaleAspectFill
        profileImageView.layer.cornerRadius = 2
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = UIColor.red
        profileImageView.profilePresenterDelegate = self
        
        let photo = photos.object(at: section) as! NSMutableDictionary
        let query = PFUser.query()
        query?.whereKey("username", equalTo: photo.value(forKey: "username") as! String)
        query?.findObjectsInBackground(block: { (users: [PFObject]?, error: Error?) -> Void in
            if let users = users {
                let pfImageView = PFImageView()
                if users.count > 0 {
                    let user = users[0]
                    profileImageView.user = user as? PFUser
                    if let _ = user.value(forKey: "photo"){
                        pfImageView.file = users[0].value(forKey: "photo") as? PFFile
                        pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                            if let error = error {
                                // Log details of the failure
                                print("Error: \(error) \(error.localizedDescription)")
                                
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
        let username = photo.value(forKey: "username") as? String
        usernameLabel.username = username
        usernameLabel.text = username
        usernameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16.5)
        usernameLabel.textColor = UIColor.red
        usernameLabel.sizeToFit()
        usernameLabel.profilePresenterDelegate = self
        
        /*
         USERNAME STYLE
         
         // Username Box
         var usernameBoxView = UIView(frame: CGRect(x: 8 + kProfileWidthHeight, y: 8, width: Int(usernameLabel.frame.width) + 16, height: kProfileWidthHeight))
         usernameBoxView.backgroundColor = UIColor.redColor()
         */
        
        headerView.insertSubview(profileImageView, at: 0)
        headerView.insertSubview(usernameLabel, at: 0)
        headerView.insertSubview(blurView, at: 0)
        blurView.autoPinEdgesToSuperviewEdges()
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(self.kHeaderHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photo = self.photos.object(at: indexPath.section) as? NSMutableDictionary
        var commentOffset = 2
        var hasFaves = false
        if let numFaves = photo?.value(forKey: "numFaves") as? Int {
            if numFaves > 0 {
                hasFaves = true
                commentOffset += 1
            }
        }
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoVideoCell", for: indexPath) as! PhotoVideoCell
            
            cell.setUpCell(photo)
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
            
            cell.delegate = self
            cell.setUpCell(photo)
            return cell
        default:
            if indexPath.row == 2 && hasFaves {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "FavesCell", for: indexPath) as! FavesCell
                
                cell.setUpCell(photo)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
                cell.commentIndex = indexPath.row - commentOffset
                cell.usernameLabel.profilePresenterDelegate = self
                cell.setUpCell(photo)
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 2
        let photo = photos.object(at: section) as? NSMutableDictionary
        if let numFaves = photo?.value(forKey: "numFaves") as? Int {
            if numFaves > 0 {
                numRows += 1
            }
        }
        if let numComments = photo?.value(forKey: "numComments") as? Int {
            numRows += numComments
        }
        return numRows
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PhotoVideoCell {
            let photo = self.photos.object(at: indexPath.section) as! NSMutableDictionary
            if let _ = photo.value(forKey: "videoFile") as? PFFile {
                cell.removeVideoPlayer()
            }
        }
    }
}


// MARK: - Refresh Helpers

extension ReelViewController {
    
    func firstLoad() {
        let animationDuration = 0.5
        UIView.transition(with: self.deltLoadingView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
            self.deltLoadingView.startAnimating()
            self.deltLoadingView.isHidden = false
        }, completion: nil)
        self.refreshData {
            UIView.transition(with: self.deltLoadingView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
                self.deltLoadingView.isHidden = true
                self.deltLoadingView.stopAnimating()
            }, completion: nil)
        }
    }
    
    func refreshData() {
        self.refreshControl?.beginRefreshing()
        self.refreshData { 
            self.refreshControl?.endRefreshing()
        }
    }
    
    // TODO: Just pass around PFObject, no need to deserialize...
    func refreshData(completion: (() -> ())?) {
        let query = PFQuery(className: "Photo")
        query.order(byAscending: "createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if let error = error {
                // Log details of the failure
                print("Error: \(error) \(error.localizedDescription)")
                
            } else {
                print("Successfully retrieved \(objects!.count) photos.")
                
                if let objects = objects {
                    self.photos.removeAllObjects()
                    
                    print("Adding photos to array")
                    var i = 0
                    
                    for object in objects {
                        let photo = NSMutableDictionary()
                        photo.setObject(object.objectId!, forKey: "objectId" as NSCopying)
                        
                        if let imageFile = object.object(forKey: "imageFile") {
                            photo.setObject(imageFile, forKey: "imageFile" as NSCopying)
                        }
                        
                        // VIDEO
                        if let videoFile = object.object(forKey: "videoFile") {
                            photo.setObject(videoFile, forKey: "videoFile" as NSCopying)
                        }
                        
                        if let username = object.object(forKey: "username") as? String {
                            photo.setObject(username, forKey: "username" as NSCopying)
                        }
                        if let favedBy = object.object(forKey: "favedBy") as? [String] {
                            photo.setObject(favedBy, forKey: "favedBy" as NSCopying)
                        }
                        if let numFaves = object.object(forKey: "numFaves") as? Int {
                            photo.setObject(numFaves, forKey: "numFaves" as NSCopying)
                        }
                        if let flagged = object.object(forKey: "flagged") as? Bool {
                            photo.setObject(flagged, forKey: "flagged" as NSCopying)
                        }
                        if let numFlags = object.object(forKey: "numFlags") as? Int {
                            photo.setObject(numFlags, forKey: "numFlags" as NSCopying)
                        }
                        if let numComments = object.object(forKey: "numComments") as? Int {
                            photo.setObject(numComments, forKey: "numComments" as NSCopying)
                        }
                        if let comments = object.object(forKey: "comments") as? [[String]] {
                            photo.setObject(comments, forKey: "comments" as NSCopying)
                        }
                        
                        print("\(i += 1)")
                        
                        self.photos.insert(photo, at: 0)
                    }
                }
                
                self.tableView.reloadData()
                completion?()
                self.deltLoadingView.stopAnimating()
            }
        }
    }
    
    func onRefresh() {
        self.refreshData()
    }
}


// MARK: - Button Cell Delegate

extension ReelViewController: ButtonCellDelegate {
    func addComment(_ photo: NSMutableDictionary?) {
        commentPhoto = photo
        self.performSegue(withIdentifier: "addCommentSegue", sender: self) // segue to CommentViewController
    }
    
    func updateFaved(_ photo: NSMutableDictionary?, didUpdateFaved faved: Bool) {
        let query = PFQuery(className: "Photo")
        let objectId = photo?.value(forKey: "objectId") as! String
        query.getObjectInBackground(withId: objectId) { (photo: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            } else if let photo = photo {
                
                if let username = PFUser.current()?.username {
                    // Increment or decrement fave count accordingly.
                    if faved {
                        photo.add(username, forKey: "favedBy")
                        photo.incrementKey("numFaves")
                    } else {
                        photo.remove(username, forKey: "favedBy")
                        photo.incrementKey("numFaves", byAmount: -1)
                    }
                }
                
                photo.saveInBackground(block: { (completed: Bool, eror: Error?) -> Void in
                    if let error = error {
                        // Log details of the failure
                        print("Error: \(error) \(error.localizedDescription)")
                        
                    } else {
                        self.refreshData() // FIXME: Makes for glitchy scrolling.
                    }
                })
            }
        }
    }
    
    func updateFlagged(_ photo: NSMutableDictionary?, flagged: Bool) {
        if flagged {
            let alert = UIAlertController(title: "Post Flagged", message: "Administrators have been notified and this post will be reviewed.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let query = PFQuery(className: "Photo")
        let objectId = photo?.value(forKey: "objectId") as! String
        query.getObjectInBackground(withId: objectId) { (photo: PFObject?, error: Error?) -> Void in
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
                
                photo.saveInBackground(block: { (completed: Bool, eror: Error?) -> Void in
                    if let error = error {
                        // Log details of the failure
                        print("Error: \(error) \(error.localizedDescription)")
                        
                    } else {
                        self.refreshData()  // FIXME: Makes for glitchy scrolling.
                    }
                })
            }
        }
    }
}


// MARK: - Actions

extension ReelViewController {
    @IBAction func onAddButtonTapped(_ sender: AnyObject) {
        self.present(self.chooseMediaAlertController, animated: true, completion: nil)
    }
}


// MARK: - Image Picker Controller Delegate

extension ReelViewController: UIImagePickerControllerDelegate {
    // Triggered when the user finishes taking an image. Saves the chosen image to our temporary
    // uploadPhoto variable, and dismisses the image picker view controller. Once the image picker
    // view controller is dismissed (a.k.a. inside the completion handler) we modally segue to
    // show the "Location selection" screen. --Nick Troccoli
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Photo.
        if info[UIImagePickerControllerMediaType] as! String == kUTTypeImage as String {
            self.uploadPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
            
            // Video.
        } else {
            let videoUrl = info[UIImagePickerControllerMediaURL] as! URL
            let videoData = try? Data(contentsOf: videoUrl)
            self.uploadVideo = PFFile(name: "video.mp4", data: videoData!)
            
            // Set video thumbnail image.
            let asset = AVAsset(url: videoUrl)
            let generator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            let time = CMTimeMake(1, 1)
            let imageRef = try! generator.copyCGImage(at: time, actualTime: nil)
            self.uploadPhoto = UIImage(cgImage: imageRef)
        }
        
        let storyboard = UIStoryboard(name: "Reel", bundle: nil)
        let captionNC = storyboard.instantiateViewController(withIdentifier: "CaptionNC") as! UINavigationController
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
        
        photo["username"] = PFUser.current()?.username
        photo["faved"] = false
        photo["numFaves"] = 0
        photo["flagged"] = false
        photo["numFlags"] = 0
        
        var comments = [[String]]()
        if let caption = caption {
            photo["numComments"] = 1
            
            comments.append([PFUser.current()!.username!, caption])
        } else {
            photo["numComments"] = 0
        }
        photo["comments"] = comments
        photo.saveInBackground(block: { (completed: Bool, error: Error?) -> Void in
            if let error = error {
                // Log details of the failure
                print("Error: \(error) \(error.localizedDescription)")
                
            } else {
                self.refreshData()
            }
        })
        
        if let numPhotosPosted = PFUser.current()!.object(forKey: "numPhotosPosted") as? Int {
            PFUser.current()?.setObject(numPhotosPosted + 1, forKey: "numPhotosPosted")
        } else {
            PFUser.current()?.setObject(1, forKey: "numPhotosPosted")
        }
        PFUser.current()?.saveInBackground()
    }
}


// MARK: - Comment View Controller Delegate

extension ReelViewController: CommentViewControllerDelegate {
    func commentViewController(didEnterComment comment: String) {
        let query = PFQuery(className: "Photo")
        let objectId = commentPhoto?.value(forKey: "objectId") as! String
        query.getObjectInBackground(withId: objectId) { (photo: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error)
            } else if let photo = photo {
                var commentPair: [String]
                if let username = PFUser.current()?.username {
                    commentPair = [username, comment]
                } else {
                    commentPair = ["", comment]
                }
                
                photo.add(commentPair, forKey: "comments")   // Add comment
                photo.incrementKey("numComments")                  // Increment comment count
                
                photo.saveInBackground(block: { (completed: Bool, eror: Error?) -> Void in
                    if let error = error {
                        // Log details of the failure
                        print("Error: \(error) \(error.localizedDescription)")
                        
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCommentSegue" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.viewControllers.first as! CommentViewController
            vc.delegate = self
            vc.photo = self.commentPhoto
        } else {
            let vc = segue.destination as! PhotoDetailsViewController
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            vc.selectedPhoto = self.photos[indexPath.section] as! NSMutableDictionary
        }
    }
}


// MARK: - Photo Video Cell Delegate

extension ReelViewController: PhotoVideoCellDelegate {
    func presentVideoDetailViewController(videoFile file: PFFile) {
        print("PRESENTING VIDEO DETAIL")
    }
    
    // did update faved implemented in Button Cell Delegate
}


// MARK: - Transition

extension ReelViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        /*
        if presented.isKindOfClass(PhotoDetailViewController) || presented.isKindOfClass(VideoDetailViewController) {
        self.transition.originFrame = self.transitioningCellFrame
        self.transition.presenting = true
        return self.transition
        }
        */
        
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transition.presenting = false
        return self.transition
    }
}
