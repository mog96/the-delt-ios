//
//  AddUserViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/9/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class AddUserViewController: UIViewController {
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTextFieldBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var emailTextFieldBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameTextFieldBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var passwordTextFieldBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var addUserButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Name text field.
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.nameTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        self.nameTextField.delegate = self
        self.nameTextField.returnKeyType = .Next
        
        // Email text field.
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.emailTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        self.emailTextField.delegate = self
        self.nameTextField.nextTextField = self.emailTextField
        self.emailTextField.keyboardType = .EmailAddress
        self.emailTextField.returnKeyType = .Next
        
        // Username text field.
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.usernameTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        usernameTextField.delegate = self
        self.emailTextField.nextTextField = self.usernameTextField
        self.usernameTextField.returnKeyType = .Next
        
        // Password text field.
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.passwordTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        passwordTextField.delegate = self
        self.usernameTextField.nextTextField = self.passwordTextField
        self.passwordTextField.returnKeyType = .Go
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Helpers

extension AddUserViewController {
    func dismiss() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}


// MARK: - Text Field Delegate

extension AddUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField.returnKeyType {
        case .Go:
            self.addUserButton.sendActionsForControlEvents(.TouchUpInside)
        default:
            textField.nextTextField?.becomeFirstResponder()
        }
        return true
    }
}


// MARK: - Actions

extension AddUserViewController {
    @IBAction func onAddUserButtonTapped(sender: AnyObject) {
        
        print("ADD USER")
        
        let user = PFUser()
        user.email = emailTextField.text
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        user["totalNumFavesReceived"] = 0
        user["totalNumPhotosPosted"] = 0
        
        // other fields can be set just like with PFObject
        // user["phone"] = "415-392-0202"
        
        let currentHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        currentHUD.label.text = "Adding User..."
        
        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                
                // Show the errorString somewhere and let the user try again.
                print("Signup error: \(errorString)")
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                let invalidSignupAlertVC = UIAlertController(title: "Email or Username Taken", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                invalidSignupAlertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(invalidSignupAlertVC, animated: true, completion: nil)
                
            } else {
                
                // Hooray! Let them use the app now.
                print("SIGNUP SUCCESSFUL")
                
                currentHUD.label.text = "User Added!"
                currentHUD.mode = MBProgressHUDMode.CustomView
                currentHUD.customView =  UIImageView(image: UIImage(named: "reset_success"))
                let delay: NSTimeInterval = 2.0
                currentHUD.hideAnimated(true, afterDelay: delay)
                self.performSelector(#selector(self.dismiss), withObject: self, afterDelay: delay)
            }
        }
    }
    
    @IBAction func onBackgroundTapped(sender: AnyObject) {
        self.view.endEditing(true)
    }
}
