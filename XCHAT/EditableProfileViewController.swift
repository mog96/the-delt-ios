
//
//  EditableProfileViewController.swift
//  XCHAT
//
//  Created by Jim Cai on 5/21/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class EditableProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var uploadPhoto: UIImage?
    var choosingPhoto = false
    let bioTextViewPlaceholder = "Tell your crew a little bit about yourself."
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var backgroundPhotoImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    /*
    @IBOutlet weak var backgroundPhoto: UIImageView!
    @IBOutlet var backGround: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var quoteText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var quote: UILabel!
    @IBOutlet weak var profilePicView: UIView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var realName: UILabel!
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var query = PFQuery(className: "User")
        
        if let name = PFUser.currentUser()?.objectForKey("name") as? String {
            nameTextField.text = name
        }
        if let username = PFUser.currentUser()?.objectForKey("username") as? String {
            usernameTextField.text = "@" + username
        }
        if let year = PFUser.currentUser()?.objectForKey("class") as? String {
            yearTextField.text = "Class of " + year
        }
        
        if let bio = PFUser.currentUser()?.objectForKey("quote") as? String {
            self.bioTextView.text = bio
        } else {
            setPlaceholderText(bioTextView)
        }
        
        if let phoneNumber = PFUser.currentUser()?.objectForKey("phone") as? String {
            phoneNumberTextField.text = "Class of " + phoneNumber
        }
        
        if let email = PFUser.currentUser()?.objectForKey("email") as? String {
            phoneNumberTextField.text = email
        }
        
        if let photo = PFUser.currentUser()?.objectForKey("photo") as? PFFile {
            var pfImageView = PFImageView()
            
            pfImageView.file = photo as PFFile
            pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                if error == nil {
                    self.photoImageView.image = image
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
        
        if let backgroundPhoto = PFUser.currentUser()?.objectForKey("backgroundPhoto") as? PFFile {
            var pfImageView = PFImageView()
            
            pfImageView.file = backgroundPhoto as PFFile
            pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                if error == nil {
                    self.backgroundPhotoImageView.image = image
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: TextField
    
    func setPlaceholderText(textView: UITextView) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            textView.text = self.bioTextViewPlaceholder
        })
        textView.textColor = UIColor.lightGrayColor()
    }

    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()

        if count(nameTextField.text) > 0 {
            PFUser.currentUser()?.setObject(nameTextField.text, forKey: "name")
        }
        if count(usernameTextField.text) > 0 {
            PFUser.currentUser()?.setObject(usernameTextField.text, forKey: "username")
        }
        if count(yearTextField.text) > 0 {
            PFUser.currentUser()?.setObject(yearTextField.text, forKey: "year")
        }
        
        if bioTextView.text != bioTextViewPlaceholder {
            PFUser.currentUser()?.setObject(bioTextView.text, forKey: "quote")
        }
        
        if count(phoneNumberTextField.text) > 0 {
            PFUser.currentUser()?.setObject(phoneNumberTextField.text, forKey: "phone")
        }
        if count(emailTextField.text) > 0 {
            PFUser.currentUser()?.setObject(emailTextField.text, forKey: "email")
        }

        PFUser.currentUser()?.saveInBackgroundWithBlock({ (result: Bool, error: NSError?) -> Void in
            if error != nil {
                
                // Print some kind of error to clients
                println(error?.description)
            } else {
                self.viewDidLoad()
            }
        })

    }
    
    
    // MARK: Keyboard
    
    func keyboardWillShow(notification: NSNotification){
        let userInfo = notification.userInfo
        let kbSize = userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue()
        let newHeight = scrollView.frame.height - kbSize!.height
        
        scrollViewBottomSpaceConstraint.constant = kbSize!.height
        
        println("KEYBOARD HEIGHT \(kbSize!.height)")
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in
                
        })
        
    }
    
    func keyboardWillHide(notification: NSNotification){
        scrollViewBottomSpaceConstraint.constant = 0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in

        })
    }
    
    
    // MARK: Actions
    
    @IBAction func onScreenTapped(sender: AnyObject) {
        println("TRUE")
        view.endEditing(true)
    }
    
    @IBAction func onPhotoTapped(sender: AnyObject) {
        choosingPhoto = true
        
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = true
        imageVC.sourceType = .PhotoLibrary
        presentViewController(imageVC, animated: true, completion: nil) // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
    
    @IBAction func onBackgroundPhotoTapped(sender: AnyObject) {
        choosingPhoto = false
        
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = false
        imageVC.sourceType = .PhotoLibrary
        presentViewController(imageVC, animated: true, completion: nil) // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
    
    
    // MARK: ImagePickerController
    
    // Triggered when the user finishes taking an image.  Saves the chosen image
    // to our temporary chosenImage variable, and dismisses the
    // image picker view controller.  Once the image picker view controller is
    // dismissed (a.k.a. inside the completion handler) we modally segue to
    // show the "Location selection" screen (WRITTEN BY NICK TROCCOLI)
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        uploadPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
            let imageData = UIImageJPEGRepresentation(self.uploadPhoto, 100)
            let imageFile = PFFile(name: (PFUser.currentUser()?.email)!+".jpeg", data: imageData)
            if self.choosingPhoto {
                self.photoImageView.image = self.uploadPhoto
                PFUser.currentUser()?.setObject(imageFile, forKey: "photo")
                
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if error == nil {
                        
                        //println("successfully uploaded photo!")
                        self.viewDidLoad()
                    } else {
                        println(error)
                    }
                })
            } else {
                self.backgroundPhotoImageView.image = self.uploadPhoto
                PFUser.currentUser()?.setObject(imageFile, forKey: "backgroundPhoto")
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if error == nil {
                        
                        //println("successfully uploaded photo!")
                        self.viewDidLoad()
                    } else {
                        println(error)
                    }
                })
            }
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
