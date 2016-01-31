
//
//  EditableProfileViewController.swift
//  XCHAT
//
//  Created by Jim Cai on 5/21/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class EditableProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundPhotoImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    var bioTextViewPlaceholder: String!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var backgroundPhotoImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var backgroundPhotoTapGestureRecognizer: UITapGestureRecognizer!
    
    var uploadPhoto: UIImage?
    var choosingBackgroundPhoto = false
    let yearPrefix = "Class of "
    let descriptionString = "Tell the house a little bit about yourself."
    let membersViewDescriptionString = "Nothing interesting about me."
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var editable = true
    var user: PFUser?
    
    let kYearLength = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Add keyboard observers.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // Set delegates.
        self.nameTextField.delegate = self
        self.usernameTextField.delegate = self
        self.yearTextField.delegate = self
        self.bioTextView.delegate = self
        self.phoneNumberTextField.delegate = self
        self.emailTextField.delegate = self
        
        if !self.editable {
            self.backgroundPhotoTapGestureRecognizer.enabled = false
            self.photoButton.enabled = false
            self.nameTextField.enabled = false
            self.usernameTextField.enabled = false
            self.yearTextField.enabled = false
            self.phoneNumberTextField.enabled = false
            self.emailTextField.enabled = false
            self.bioTextView.editable = false
        }
        
        self.photoImageView.layer.cornerRadius = 3
        self.photoImageView.clipsToBounds = true
        self.photoButton.layer.cornerRadius = 3
        self.photoButton.clipsToBounds = true
        
        self.bioTextViewPlaceholder = self.editable ? self.descriptionString : self.membersViewDescriptionString
        self.setupView(editable ? PFUser.currentUser() : self.user)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if !self.editable {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.translucent = true
            self.navigationController?.view.backgroundColor = UIColor.clearColor()
            
            self.appDelegate.hamburgerViewController.panGestureRecognizer.enabled = false
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
        // self.navigationController?.view.backgroundColor = UIColor.clearColor()
        
        if !self.editable {
            self.photoImageView.image = nil
            self.backgroundPhotoImageView.image = nil
            self.appDelegate.hamburgerViewController.panGestureRecognizer.enabled = true
        }
    }
    
    
    // MARK: - Setup Helpers
    
    func setupView(user: PFUser?) {
        if let name = user?.objectForKey("name") as? String {
            self.nameTextField.text = name
        }
        
        if let username = user?.objectForKey("username") as? String {
            self.usernameTextField.text = "@" + username
        }
        
        if let year = user?.objectForKey("class") as? String {
            self.yearTextField.text = "Class of " + year
        } else if !self.editable {
            self.yearTextField.text = "Class of 6969"
        }
        
        if let bio = user?.objectForKey("quote") as? String {
            self.bioTextView.text = bio
        } else {
            self.bioTextView.text = self.bioTextViewPlaceholder
        }
        
        if let phoneNumber = user?.objectForKey("phone") as? String {
            self.phoneNumberTextField.text = phoneNumber
        }
        
        if let email = user?.objectForKey("email") as? String {
            emailTextField.text = email
        }
        
        // Photo.
        if let photo = user?.objectForKey("photo") as? PFFile {
            let pfImageView = PFImageView()
            
            pfImageView.file = photo as PFFile
            pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error.userInfo)")
                    
                } else {
                    self.photoImageView.image = image
                    self.photoButton.setTitle("", forState: .Normal)
                }
            }
        } else if !self.editable {
            self.photoButton.setTitle("", forState: .Normal)
        }
        
        // Background photo.
        if let backgroundPhoto = user?.objectForKey("backgroundPhoto") as? PFFile {
            let pfImageView = PFImageView()
            
            pfImageView.file = backgroundPhoto as PFFile
            pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error.userInfo)")
                    
                } else {
                    self.backgroundPhotoImageView.image = image
                }
            }
        }
        backgroundPhotoImageViewWidthConstraint.constant = UIScreen.mainScreen().bounds.width
    }
    
    
    // MARK: Disable Rotation
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    
    // MARK: TextField Delegate

    func textFieldDidEndEditing(textField: UITextField) {
        if !(self.yearTextField.text!.hasPrefix(self.yearPrefix) && self.yearTextField.text!.characters.count == self.yearPrefix.characters.count + kYearLength) {
            self.yearTextField.text = ""
        }
        textField.resignFirstResponder()
        self.saveData()
    }
    
    
    // MARK: TextView Delegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        if self.bioTextView.text == self.bioTextViewPlaceholder {
            self.bioTextView.text = ""
        }
        self.bioTextView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        // User deletes all text in the text view.
        if self.bioTextView.text!.characters.count == 0 && self.editable {
            self.bioTextView.text = self.bioTextViewPlaceholder
        }
        self.bioTextView.resignFirstResponder()
        self.saveData()
    }
    
    
    // MARK: Keyboard
    
    func keyboardWillShow(notification: NSNotification){
        let userInfo = notification.userInfo
        
        self.scrollViewBottomSpaceConstraint.constant = (userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.height)!
        
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
        view.endEditing(true)
    }
    
    @IBAction func onPhotoButtonTapped(sender: AnyObject) {
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = true
        imageVC.sourceType = .PhotoLibrary
        presentViewController(imageVC, animated: true, completion: nil) // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
    
    @IBAction func onBackgroundPhotoTapped(sender: AnyObject) {
        self.choosingBackgroundPhoto = true
        
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = false
        imageVC.sourceType = .PhotoLibrary
        
        // UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        presentViewController(imageVC, animated: true, completion: nil) // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
    
    
    // MARK: ImagePickerController
    
    // Triggered when the user finishes taking an image.  Saves the chosen image
    // to our temporary chosenImage variable, and dismisses the
    // image picker view controller.  Once the image picker view controller is
    // dismissed (a.k.a. inside the completion handler) we modally segue to
    // show the "Location selection" screen (WRITTEN BY NICK TROCCOLI)
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
        
        self.uploadPhoto = info[self.choosingBackgroundPhoto ? UIImagePickerControllerOriginalImage : UIImagePickerControllerEditedImage] as? UIImage
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
            // TODO: Handle case where upload photo is nil.
            let imageData = UIImageJPEGRepresentation(self.uploadPhoto!, 100)
            let imageFile = PFFile(name: (PFUser.currentUser()?.username)! + ".jpeg", data: imageData!)
            
            if self.choosingBackgroundPhoto {
                
                // Set background photo before uploading.
                UIView.transitionWithView(self.backgroundPhotoImageView, duration: 0.2, options: .TransitionCrossDissolve, animations: {
                    self.backgroundPhotoImageView.image = self.uploadPhoto
                    }, completion: nil)
                
                // Save current user.
                PFUser.currentUser()?.setObject(imageFile!, forKey: "backgroundPhoto")
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if error == nil {
                        self.saveData()
                    } else {
                        print(error)
                    }
                })
            } else {
                
                print("SAVING PROFILE PHOTO")
                
                // Set profile image before uploading.
                UIView.transitionWithView(self.photoImageView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                    self.photoImageView.image = self.uploadPhoto
                    self.photoButton.setTitle("", forState: .Normal)
                }, completion: nil)
                
                // Save current user.
                PFUser.currentUser()?.setObject(imageFile!, forKey: "photo")
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if error == nil {
                        self.saveData()
                    } else {
                        print(error)
                    }
                })
            }
        })
    }
    
    
    // MARK: Save Data
    
    // TODO: Save user bios to a separate table, so that people can change other people's bios.
    
    // Saves data (not photos) and updates view.
    func saveData() {
        if self.editable {
            // Set name.
            if self.nameTextField.text!.characters.count > 0 {
                PFUser.currentUser()?.setObject(self.nameTextField.text!, forKey: "name")
            } else {
                PFUser.currentUser()?.removeObjectForKey("name")
            }
            
            // Set username.
            if self.usernameTextField.text!.characters.count > 0 && self.usernameTextField.text! != "@" {
                let username = self.usernameTextField.text!.substringFromIndex(self.usernameTextField.text!.startIndex.advancedBy(1))
                PFUser.currentUser()?.setObject(username, forKey: "username")
            } else {
                PFUser.currentUser()?.removeObjectForKey("username")
            }
            
            // Set year. Strictly requires Class of XXXX format.
            if self.yearTextField.text!.hasPrefix(self.yearPrefix) && self.yearTextField.text!.characters.count == self.yearPrefix.characters.count + kYearLength {
                if let year = Int(self.yearTextField.text!.substringFromIndex(self.yearTextField.text!.startIndex.advancedBy(self.yearPrefix.characters.count))) {
                    
                    PFUser.currentUser()?.setObject(year, forKey: "year")
                }
            } else {
                PFUser.currentUser()?.setObject(6969, forKey: "year")
            }
            
            // Set phone number.
            if phoneNumberTextField.text!.characters.count > 0 {
                PFUser.currentUser()?.setObject(phoneNumberTextField.text!, forKey: "phone")
            } else {
                PFUser.currentUser()?.removeObjectForKey("phone")
            }
            
            // Set email.
            if emailTextField.text!.characters.count > 0 {
                PFUser.currentUser()?.setObject(emailTextField.text!, forKey: "email")
            } else {
                PFUser.currentUser()?.removeObjectForKey("email")
            }
            
            // Set bio.
            if self.bioTextView.text.characters.count > 0 && bioTextView.text != self.bioTextViewPlaceholder {
                PFUser.currentUser()?.setObject(bioTextView.text, forKey: "quote")
            } else {
                PFUser.currentUser()?.removeObjectForKey("quote")
            }
        }
        
        // Save data.
        PFUser.currentUser()?.saveInBackgroundWithBlock({ (result: Bool, error: NSError?) -> Void in
            if error != nil {
                print(error?.description)
                
            } else {
                PFUser.currentUser()?.fetchIfNeededInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
                    if error == nil {
                        
                        // Reload profile view.
                        self.viewDidLoad()
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                        
                        // Reload menu.
                        self.appDelegate.menuViewController.tableView.reloadData()
                        
                    } else {
                        print(error)
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
