//
//  LoginViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginBoxView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loginBoxView.layer.cornerRadius = 2
        loginBoxView.layer.masksToBounds = true
        
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        usernameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    
    @IBAction func signupPressed(sender: AnyObject) {
        var user = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        user.email = usernameTextField.text
        // other fields can be set just like with PFObject
        // user["phone"] = "415-392-0202"
        
        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo?["error"] as? NSString
                // Show the errorString somewhere and let the user try again.
                
                println("SIGNUP FAILED")
            } else {
                // Hooray! Let them use the app now.
                println("SIGNUP SUCCESSFUL")

            }
        }
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(usernameTextField.text, password: passwordTextField.text) { (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                println("LOGIN SUCCESSFUL")
                
                self.usernameTextField.resignFirstResponder()
                self.passwordTextField.resignFirstResponder()
                
                self.performSegueWithIdentifier("loginSegue", sender: self)
            } else {
                println("LOGIN FAILED")
            }
        }
    }
    
    @IBAction func onScreenTapped(sender: AnyObject) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.        
       
        var hamburgerViewController =  segue.destinationViewController as! HamburgerViewController
        var menuViewController = storyboard!.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        
        hamburgerViewController.menuViewController = menuViewController
        menuViewController.hamburgerViewController = hamburgerViewController
        
        // TODO: SET START VIEW TO THREADS
        var chatNavigationController = storyboard!.instantiateViewControllerWithIdentifier("Messages") as! MessageViewController
        
        hamburgerViewController.contentViewController = chatNavigationController
    }
    
}
