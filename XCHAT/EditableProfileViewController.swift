
//
//  EditableProfileViewController.swift
//  XCHAT
//
//  Created by Jim Cai on 5/21/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import MBProgressHUD
import Parse
import ParseUI

protocol ProfilePresenterDelegate {
    func profilePresenter(wasTappedWithUser user: PFUser?)
    func profilePresenter(wasTappedWithUsername username: String?)
}

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
    let kYearPrefix = "Class of "
    
    let kBioDescriptionString = "Tell the house a little bit about yourself."
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var editable = true
    var user: PFUser?
    var username: String?
    var currentHUD = MBProgressHUD()
    
    let kYearLength = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Add keyboard observers.
        NotificationCenter.default.addObserver(self, selector: #selector(EditableProfileViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditableProfileViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Set delegates.
        self.nameTextField.delegate = self
        self.usernameTextField.delegate = self
        self.yearTextField.delegate = self
        self.bioTextView.delegate = self
        self.phoneNumberTextField.delegate = self
        self.emailTextField.delegate = self
        
        if !self.editable {
            self.backgroundPhotoTapGestureRecognizer.isEnabled = false
            self.photoButton.isEnabled = false
            self.photoButton.isHidden = true
            self.nameTextField.isEnabled = false
            self.usernameTextField.isEnabled = false
            self.yearTextField.isEnabled = false
            self.phoneNumberTextField.isEnabled = false
            self.emailTextField.isEnabled = false
            self.bioTextView.isEditable = false
            
            // Hide placeholders.
            let textItems = [self.nameTextField, self.usernameTextField, self.yearTextField, self.bioTextView, self.phoneNumberTextField, self.emailTextField] as [Any]
            for textItem in textItems {
                if let item = textItem as? UITextField {
                    item.text = nil
                    item.placeholder = nil
                } else if let item = textItem as? UITextView {
                    item.text = nil
                }
            }
        }
        
        self.photoImageView.layer.cornerRadius = 3
        self.photoImageView.clipsToBounds = true
        self.photoButton.layer.cornerRadius = 3
        self.photoButton.clipsToBounds = true
        
        self.bioTextViewPlaceholder = self.kBioDescriptionString
        if self.editable {
            self.setupView(PFUser.current())
        } else {
            if self.user != nil {
                self.setupView(self.user)
            } else if self.username != nil {
                let query = PFUser.query()
                query?.whereKey("username", equalTo: self.username!)
                query?.findObjectsInBackground(block: { (users: [PFObject]?, error: Error?) -> Void in
                    if let users = users {
                        if users.count > 0 {
                            self.user = users[0] as? PFUser
                            self.setupView(self.user)
                        }
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.backgroundPhotoImageViewWidthConstraint.constant = UIScreen.main.bounds.width
        
        if !self.editable {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = UIColor.clear
            
            self.appDelegate.hamburgerViewController?.panGestureRecognizer.isEnabled = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        
        if !self.editable {
            self.photoImageView.image = nil
            self.backgroundPhotoImageView.image = nil
            self.appDelegate.hamburgerViewController?.panGestureRecognizer.isEnabled = true
        }
    }
    
    
    // MARK: - Setup Helpers
    
    fileprivate func setupView(_ user: PFUser?) {
        if let name = user?.object(forKey: "name") as? String {
            self.nameTextField.text = name
        }
        
        if let username = user?.object(forKey: "username") as? String {
            self.usernameTextField.text = "@" + username
        }
        
        if let year = user?["classOf"] as? Int {
            self.yearTextField.text = self.kYearPrefix + String(year)
        }
        
        if let bio = user?.object(forKey: "quote") as? String {
            self.bioTextView.text = bio
        } else {
            if self.editable {
                self.bioTextView.text = self.bioTextViewPlaceholder
            }
        }
        
        if let phoneNumber = user?.object(forKey: "phone") as? String {
            self.phoneNumberTextField.text = phoneNumber
        }
        
        if let email = user?.object(forKey: "email") as? String {
            emailTextField.text = email
        }
        
        // Photo.
        if let photo = user?.object(forKey: "photo") as? PFFile {
            let pfImageView = PFImageView()
            
            pfImageView.file = photo as PFFile
            pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error.localizedDescription)")
                    
                } else {
                    self.photoImageView.image = image
                    self.photoButton.setTitle("", for: UIControlState())
                }
            }
        } else if !self.editable {
            self.photoButton.setTitle("", for: UIControlState())
        }
        
        // Background photo.
        if let backgroundPhoto = user?.object(forKey: "backgroundPhoto") as? PFFile {
            let pfImageView = PFImageView()
            
            pfImageView.file = backgroundPhoto as PFFile
            pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error._userInfo)")
                    
                } else {
                    self.backgroundPhotoImageView.image = image
                }
            }
        }
    }
    
    
    // MARK: Disable Rotation
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    
    // MARK: TextField Delegate

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.saveData()
    }
    
    
    // MARK: TextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.bioTextView.text == self.bioTextViewPlaceholder {
            self.bioTextView.text = ""
        }
        self.bioTextView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        // User deletes all text in the text view.
        if self.bioTextView.text!.characters.count == 0 && self.editable {
            self.bioTextView.text = self.bioTextViewPlaceholder
        }
        self.bioTextView.resignFirstResponder()
        self.saveData()
    }
    
    
    // MARK: Keyboard
    
    func keyboardWillShow(_ notification: Notification){
        let userInfo = notification.userInfo
        
        self.scrollViewBottomSpaceConstraint.constant = ((userInfo?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.height)
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in
                
        })
        
    }
    
    func keyboardWillHide(_ notification: Notification){
        scrollViewBottomSpaceConstraint.constant = 0
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in

        })
    }
    
    
    // MARK: Actions
    
    @IBAction func onScreenTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func onPhotoButtonTapped(_ sender: AnyObject) {
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = true
        imageVC.sourceType = .photoLibrary
        present(imageVC, animated: true, completion: nil) // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
    
    @IBAction func onBackgroundPhotoTapped(_ sender: AnyObject) {
        self.choosingBackgroundPhoto = true
        
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = false
        imageVC.sourceType = .photoLibrary
        
        // UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        present(imageVC, animated: true, completion: nil) // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
    
    
    // MARK: ImagePickerController
    
    // Triggered when the user finishes taking an image.  Saves the chosen image
    // to our temporary chosenImage variable, and dismisses the
    // image picker view controller.  Once the image picker view controller is
    // dismissed (a.k.a. inside the completion handler) we modally segue to
    // show the "Location selection" screen (WRITTEN BY NICK TROCCOLI)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
        self.currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.currentHUD.label.text = "Saving..."
        
        self.uploadPhoto = info[self.choosingBackgroundPhoto ? UIImagePickerControllerOriginalImage : UIImagePickerControllerEditedImage] as? UIImage
        dismiss(animated: true, completion: { () -> Void in
            
            // TODO: Handle case where upload photo is nil.
            let imageData = UIImageJPEGRepresentation(self.uploadPhoto!, 100)
            let imageFile = PFFile(name: (PFUser.current()?.username)! + ".jpeg", data: imageData!)
            
            if self.choosingBackgroundPhoto {
                
                // Set background photo before uploading.
                UIView.transition(with: self.backgroundPhotoImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.backgroundPhotoImageView.image = self.uploadPhoto
                    }, completion: nil)
                
                // Save current user.
                PFUser.current()?.setObject(imageFile!, forKey: "backgroundPhoto")
                PFUser.current()?.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                    self.currentHUD.hide(animated: true)
                    if error == nil {
                        self.saveData()
                    } else {
                        print(error)
                    }
                })
            } else {
                
                print("SAVING PROFILE PHOTO")
                
                // Set profile image before uploading.
                UIView.transition(with: self.photoImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.photoImageView.image = self.uploadPhoto
                    self.photoButton.setTitle("", for: UIControlState())
                }, completion: nil)
                
                // Save current user.
                PFUser.current()?.setObject(imageFile!, forKey: "photo")
                PFUser.current()?.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                    self.currentHUD.hide(animated: true)
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
    
    // Saves data (not photos) and updates view.
    func saveData() {
        if self.editable {
            self.currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.currentHUD.label.text = "Saving..."
            
            // Set name.
            if self.nameTextField.text!.characters.count > 0 {
                PFUser.current()?.setObject(self.nameTextField.text!, forKey: "name")
            } else {
                PFUser.current()?.remove(forKey: "name")
            }
            // Set username.
            if self.usernameTextField.text!.characters.count > 0 && self.usernameTextField.text! != "@" {
                let username = self.usernameTextField.text!.substring(from: self.usernameTextField.text!.characters.index(self.usernameTextField.text!.startIndex, offsetBy: 1))
                PFUser.current()?.setObject(username, forKey: "username")
            } else {
                PFUser.current()?.remove(forKey: "username")
            }
            
            // Set class year.
            if self.yearTextField.text!.characters.count >= 4 {
                let classOf = self.yearTextField.text!.substring(from: self.yearTextField.text!.index(self.yearTextField.text!.endIndex, offsetBy: -4))
                if let year = Int(classOf) {
                    PFUser.current()?["classOf"] = year
                }
            }
            
            // Set phone number.
            if phoneNumberTextField.text!.characters.count > 0 {
                PFUser.current()?.setObject(phoneNumberTextField.text!, forKey: "phone")
            } else {
                PFUser.current()?.remove(forKey: "phone")
            }
            
            // Set email.
            if emailTextField.text!.characters.count > 0 {
                PFUser.current()?.setObject(emailTextField.text!, forKey: "email")
            } else {
                PFUser.current()?.remove(forKey: "email")
            }
            
            // Set bio.
            if self.bioTextView.text.characters.count > 0 && bioTextView.text != self.bioTextViewPlaceholder {
                PFUser.current()?.setObject(bioTextView.text, forKey: "quote")
            } else {
                PFUser.current()?.remove(forKey: "quote")
            }
        }
        
        // Save data.
        PFUser.current()?.saveInBackground(block: { (result: Bool, error: Error?) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                PFUser.current()?.fetchIfNeededInBackground(block: { (object: PFObject?, error: Error?) -> Void in
                    if error == nil {
                        // Reload profile view.
                        self.viewDidLoad()
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                        
                        // Reload menu.
                        self.appDelegate.menuViewController?.tableView.reloadData()
                    } else {
                        print(error!.localizedDescription)
                    }
                    self.currentHUD.hide(animated: true)
                })
            }
        })
    }
}
