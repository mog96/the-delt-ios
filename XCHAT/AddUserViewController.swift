//
//  AddUserViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/9/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse

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

        // Do any additional setup after loading the view.
        
        /*
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
                
                self.transitionToApp()
            }
        }
        */
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
    }
}
