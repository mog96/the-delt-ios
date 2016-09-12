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

        self.nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.nameTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.emailTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.usernameTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.passwordTextField.keyboardAppearance = UIKeyboardAppearance.Dark
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


// MARK: - Actions

extension AddUserViewController {
    @IBAction func onAddUserButtonTapped(sender: AnyObject) {
        print("TAPPED BEBE")
        
        let user = PFUser()
        user.email = emailTextField.text
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        user["totalNumFavesReceived"] = 0
        user["totalNumPhotosPosted"] = 0
        
        // other fields can be set just like with PFObject
        // user["phone"] = "415-392-0202"
        
        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                
                // Show the errorString somewhere and let the user try again.
                print("Signup error: \(errorString)")
                
                let invalidSignupAlertVC = UIAlertController(title: "Email or Username Taken", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                invalidSignupAlertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(invalidSignupAlertVC, animated: true, completion: nil)
                
            } else {
                
                // Hooray! Let them use the app now.
                print("SIGNUP SUCCESSFUL")
                
                let currentHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                currentHUD.labelText = "User Added!"
                currentHUD.mode = MBProgressHUDMode.CustomView
                currentHUD.customView =  UIImageView(image: UIImage(named: "reset_success"))
                currentHUD.hide(true, afterDelay: 2.0)
                
                // self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    @IBAction func onBackgroundTapped(sender: AnyObject) {
        self.view.endEditing(true)
    }
}
