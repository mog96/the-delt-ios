//
//  ReelViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/18/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse

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
        let query = PFQuery(className:"Photo")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            
            if let error = error {
                // Log details of the failure
                print("Error: \(error) \(error.userInfo)")
                
            } else {
                
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) photos.")
                
                // Do something with the found objects
                if let objects = objects {
                    print("Adding photos to array")
                    var i = 0
                    for object in objects {
                        let photo = NSMutableDictionary()
                        if let imageName = object.objectForKey("imageName") as? String {
                            photo.setObject(imageName, forKey: "imageName")
                        }
                        if let imageFile = object.objectForKey("imageFile") as? PFFile {
                            photo.setObject(imageFile, forKey: "imageFile")
                            print("\(i++)")
                        }
                        photo.setObject(object.objectId!, forKey: "objectId")
                        self.photos.addObject(photo)
                    }
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: CollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ReelCell", forIndexPath: indexPath) as! ReelGridCell
        print("\(photos.count) PHOTOS")
        let photo = photos.objectAtIndex(indexPath.item) as? NSMutableDictionary
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
            // self.performSegueWithIdentifier("addCaptionSegue", sender: self) // segue to CaptionViewController
            
            // then add below code to a protocol implementation for the CaptionViewController's protocol
            
            let imageData = UIImageJPEGRepresentation(self.chosenImage!, 100)
            let imageFile = PFFile(name: "image.jpeg", data: imageData!)
            
            let photo = PFObject(className:"Photo")
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
