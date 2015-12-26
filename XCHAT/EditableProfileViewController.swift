
//
//  EditableProfileViewController.swift
//  XCHAT
//
//  Created by Jim Cai on 5/21/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class EditableProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundPhotoImageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var backgroundPhotoImageViewWidthConstraint: NSLayoutConstraint!
    
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
    
    var uploadPhoto: UIImage?
    var choosingPhoto = false
    let yearPrefix = "Class of "
    let bioTextViewPlaceholder = "Tell your crew a little bit about yourself."
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // let query = PFQuery(className: "User")
        
        if let name = PFUser.currentUser()?.objectForKey("name") as? String {
            nameTextField.text = name
        }
        
        // FIXME: username at symbol
        if let username = PFUser.currentUser()?.objectForKey("username") as? String {
            self.usernameTextField.text = "@" + username
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
            emailTextField.text = email
        }
        
        // Photo.
        if let photo = PFUser.currentUser()?.objectForKey("photo") as? PFFile {
            let pfImageView = PFImageView()
            
            pfImageView.file = photo as PFFile
            pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error.userInfo)")
                    
                } else {
                    self.photoButton.setBackgroundImage(image, forState: UIControlState.Normal)
                    self.photoButton.setTitle("", forState: UIControlState.Normal)
                }
            }
        }
        photoButton.layer.cornerRadius = 3
        photoButton.clipsToBounds = true
        
        // Background photo.
        if let backgroundPhoto = PFUser.currentUser()?.objectForKey("backgroundPhoto") as? PFFile {
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
        
        // Add keyboard observers.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // Set delegates.
        nameTextField.delegate = self
        usernameTextField.delegate = self
        yearTextField.delegate = self
        phoneNumberTextField.delegate = self
        emailTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Disable Rotation
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    
    // MARK: TextField
    
    func setPlaceholderText(textView: UITextView) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            textView.text = self.bioTextViewPlaceholder
        })
        textView.textColor = UIColor.lightGrayColor()
    }
    

    func textFieldDidEndEditing(textField: UITextField) {
        
        print("FUCKME")
        
        textField.resignFirstResponder()
        self.saveData()
    }
    
    /*
    // MARK: TextView Protocol Implementations
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if textView.text == "" {
            setPlaceholderText(textView)
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        resizeTextView(textView)
        
        // User deletes all text in the TextView.
        if textView.text!.characters.count == 0 {
            setPlaceholderText(textView)
            textView.resignFirstResponder()
        }
    }
    */
    
    
    // MARK: Keyboard
    
    func keyboardWillShow(notification: NSNotification){
        let userInfo = notification.userInfo
        let kbSize = userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue
        // let newHeight = scrollView.frame.height - kbSize!.height
        
        scrollViewBottomSpaceConstraint.constant = kbSize!.height
        
        print("KEYBOARD HEIGHT \(kbSize!.height)")
        
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
        choosingPhoto = true
        
        print("TRUTH")
        
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        uploadPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
            // TODO: Handle case where upload photo is nil.
            let imageData = UIImageJPEGRepresentation(self.uploadPhoto!, 100)
            let imageFile = PFFile(name: (PFUser.currentUser()?.username)! + ".jpeg", data: imageData!)
            if self.choosingPhoto {
                self.photoButton.setBackgroundImage(self.uploadPhoto, forState: UIControlState.Normal)
                self.photoButton.setTitle("", forState: UIControlState.Normal)
                PFUser.currentUser()?.setObject(imageFile, forKey: "photo")
                
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if error == nil {
                        
                        //print("successfully uploaded photo!")
                        
                        self.saveData()
                        
                        // FIXME: QUESTIONABLE
                        // self.viewDidLoad()
                    } else {
                        print(error)
                    }
                })
            } else {
                self.backgroundPhotoImageView.image = self.uploadPhoto
                PFUser.currentUser()?.setObject(imageFile, forKey: "backgroundPhoto")
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if error == nil {
                        
                        //print("successfully uploaded photo!")
                        self.viewDidLoad()
                    } else {
                        print(error)
                    }
                })
            }
        })
    }
    
    
    // MARK: Save Data
    
    let kYearLength = 4
    func saveData() {
        
        // Set name.
        if self.nameTextField.text!.characters.count > 0 {
            PFUser.currentUser()?.setObject(self.nameTextField.text!, forKey: "name")
        }
        
        // Set username.
        if self.usernameTextField.text!.characters.count > 0 && self.usernameTextField.text! != "@" {
            let username = self.usernameTextField.text!.substringFromIndex(self.usernameTextField.text!.startIndex.advancedBy(1))
            PFUser.currentUser()?.setObject(username, forKey: "username")
        }
        
        // Set year.
        if self.yearTextField.text!.hasPrefix(self.yearPrefix) && self.yearTextField.text!.characters.count == self.yearPrefix.characters.count + kYearLength {
            if let year = Int(self.yearTextField.text!.substringFromIndex(self.yearTextField.text!.startIndex.advancedBy(self.yearPrefix.characters.count))) {
                
                PFUser.currentUser()?.setObject(year, forKey: "year")
            }
        }
        
        // Set bio.
        if bioTextView.text != bioTextViewPlaceholder {
            PFUser.currentUser()?.setObject(bioTextView.text, forKey: "quote")
        }
        
        // Set phone number.
        if phoneNumberTextField.text!.characters.count > 0 {
            PFUser.currentUser()?.setObject(phoneNumberTextField.text!, forKey: "phone")
        }
        
        // Set email.
        if emailTextField.text!.characters.count > 0 {
            PFUser.currentUser()?.setObject(emailTextField.text!, forKey: "email")
        }
        
        // Save data.
        PFUser.currentUser()?.saveInBackgroundWithBlock({ (result: Bool, error: NSError?) -> Void in
            if error != nil {
                
                // Print some kind of error to clients
                print(error?.description)
            } else {
                self.viewDidLoad()
                self.appDelegate.menuViewController.tableView.reloadData()
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
