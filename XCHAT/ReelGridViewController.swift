//
//  ReelViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/18/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class ReelGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var photos = NSMutableArray()
    var chosenImage: UIImage?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Refresh
    
    func refreshData() {
        var query = PFQuery(className:"Photo")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) photos.")
                
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    println("Adding photos to array")
                    var i = 0
                    for object in objects {
                        var photo = NSMutableDictionary()
                        if let imageName = object.objectForKey("imageName") as? String {
                            photo.setObject(object.objectForKey("imageName")!, forKey: "imageName")
                        }
                        if let imageFile = object.objectForKey("imageFile") as? PFFile {
                            photo.setObject(imageFile, forKey: "imageFile")
                            println("\(i++)")
                        }
                        photo.setObject(object.objectId!, forKey: "objectId")
                        self.photos.addObject(photo)
                    }
                }
                self.collectionView.reloadData()
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    
    // MARK: CollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ReelCell", forIndexPath: indexPath) as! ReelGridCell
        println("\(photos.count) PHOTOS")
        var photo = photos.objectAtIndex(indexPath.item) as? NSMutableDictionary
        cell.setUpCell(photo)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // open up selected photo
        
    }
    
    // MARK: Actions
    
    @IBAction func onAddButtonTapped(sender: AnyObject) {
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = true
        imageVC.sourceType = .PhotoLibrary
        presentViewController(imageVC, animated: true, completion: nil) // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
    
    // MARK: ImagePickerControler
    
    // Triggered when the user finishes taking an image.  Saves the chosen image
    // to our temporary chosenImage variable, and dismisses the
    // image picker view controller.  Once the image picker view controller is
    // dismissed (a.k.a. inside the completion handler) we modally segue to
    // show the "Location selection" screen
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
            // self.performSegueWithIdentifier("addCaptionSegue", sender: self) // segue to CaptionViewController
            
            // then add below code to a protocol implementation for the CaptionViewController's protocol
            
            let imageData = UIImageJPEGRepresentation(self.chosenImage, 100)
            let imageFile = PFFile(name: "image.jpeg", data: imageData)
            
            var photo = PFObject(className:"Photo")
            photo["imageName"] = "Dis a picture!" // set to caption name
            photo["imageFile"] = imageFile
            photo.saveInBackgroundWithBlock(nil)
            
        })
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
