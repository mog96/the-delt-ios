//
//  LoginViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

/*
FOR LOGIN VIEW
- transform from login to signup on signup pressed
- add email textfield on top #SEXY

- fix logout.
*/


import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginBoxView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loginBoxView.layer.cornerRadius = 2
        loginBoxView.layer.masksToBounds = true
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        emailTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    
    // Records login/signup information.
    @IBAction func signupPressed(sender: AnyObject) {
        let user = PFUser()
        user.email = emailTextField.text
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        
        // other fields can be set just like with PFObject
        // user["phone"] = "415-392-0202"
        
        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                
                // Show the errorString somewhere and let the user try again.
                print("Signup error: \(errorString)")
                
            } else {
                // Hooray! Let them use the app now.
                print("SIGNUP SUCCESSFUL")

            }
        }
    }
    
    // Logs in with username (not email) and password.
    @IBAction func loginPressed(sender: AnyObject) {
        
        // TODO: Check that text field text is not null.
        PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) { (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                
                print("LOGIN SUCCESSFUL")
                
                self.emailTextField.resignFirstResponder()
                self.usernameTextField.resignFirstResponder()
                self.passwordTextField.resignFirstResponder()
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                UIView.transitionWithView(self.view.window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    self.view.window!.rootViewController = appDelegate.hamburgerViewController
                }, completion: nil)
                
            } else {
                
                print("LOGIN FAILED")
            }
        }
    }
    
    @IBAction func onScreenTapped(sender: AnyObject) {
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    
    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        let hamburgerViewController = segue.destinationViewController as! HamburgerViewController
        let menuViewController = storyboard!.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        hamburgerViewController.menuViewController = menuViewController
        menuViewController.hamburgerViewController = hamburgerViewController
        
        // TODO: SET START VIEW TO THREADS
        let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        let chatNavigationController = chatStoryboard.instantiateViewControllerWithIdentifier("ChatNavigationController") as! UINavigationController
        hamburgerViewController.contentViewController = chatNavigationController
    }
    
}
