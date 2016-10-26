//
//  CaptionViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/24/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse

// Communicates to presenter the caption entered for the given photo.
protocol CaptionViewControllerDelegate {
    func captionViewController(didEnterCaption caption: String?)
}

class CaptionViewController: UIViewController {
    
    var photo: UIImage!
    var video: PFFile?
    var delegate: CaptionViewControllerDelegate?

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setPlaceholderText()
        self.photoImageView.image = self.photo
        self.photoImageView.clipsToBounds = true
        self.captionTextView.delegate = self
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        captionTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Helpers

extension CaptionViewController {
    func uploadPost(caption: String?) {
        let photo = PFObject(className: "Photo")
        
        let imageData = UIImageJPEGRepresentation(self.photo, 100)
        let imageFile = PFFile(name: "image.jpeg", data: imageData!)
        photo["imageFile"] = imageFile
        
        if let _ = self.video {
            photo["videoFile"] = self.video
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
                
                
                
                // DELEGATE.REFRESH DATA 
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


// MARK: - TextView

extension CaptionViewController: UITextViewDelegate {
    func setPlaceholderText() {
        captionTextView.text = "Why is this dope?"
        captionTextView.textColor = UIColor.lightGrayColor()
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGrayColor() {
            captionTextView.text = ""
            captionTextView.textColor = UIColor.blackColor()
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        if captionTextView.text!.characters.count == 0 {
            setPlaceholderText()
            captionTextView.resignFirstResponder()
        }
    }
}


// MARK: - Actions

extension CaptionViewController {
    @IBAction func onPostButtonTapped(sender: AnyObject) {
        captionTextView.resignFirstResponder()
        
        // Avoids sending delegate placeholder text.
        if captionTextView.text.characters.count > 0 {
            self.uploadPost(self.captionTextView.text)
            // delegate?.captionViewController(didEnterCaption: captionTextView.text)
        } else {
            self.uploadPost(nil)
            // delegate?.captionViewController(didEnterCaption: nil)
        }
        
//        dismissViewControllerAnimated(true, completion: { () -> Void in
//            
//            // code
//        })
    }
    
    @IBAction func onCancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onScreenTapped(sender: AnyObject) {
        self.view.endEditing(true)
    }
}
