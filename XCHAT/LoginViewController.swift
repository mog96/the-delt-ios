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
import Parse
import MessageUI

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginViewHeightConstraint: NSLayoutConstraint!
    
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
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var loginButtonOriginalColor: UIColor!
    var signupButtonOriginalColor: UIColor!
    
    var loginViewOriginalHeight: CGFloat!
    
    var textFieldOriginalHeight: CGFloat!
    
    var signupTextFieldConstraints: [NSLayoutConstraint]!
    var loginTextFieldConstraints: [NSLayoutConstraint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.nameTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        self.nameTextField.delegate = self
        
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.emailTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        self.emailTextField.delegate = self
        
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.usernameTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        usernameTextField.delegate = self
        
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.passwordTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        passwordTextField.delegate = self
        
        self.loginView.layer.cornerRadius = 2
        self.loginView.layer.masksToBounds = true
        self.loginView.setNeedsLayout()
        self.loginView.layoutIfNeeded()
        self.loginViewOriginalHeight = self.loginView.frame.height
        
        self.loginButtonOriginalColor = self.loginButton.titleColorForState(.Normal)
        self.signupButtonOriginalColor = self.signupButton.titleColorForState(.Normal)
        
        self.textFieldOriginalHeight = self.nameTextFieldHeight.constant
        
        self.signupTextFieldConstraints = [self.nameTextFieldHeight, self.nameTextFieldBottomSpacing, self.emailTextFieldHeight, self.emailTextFieldBottomSpacing]
        self.loginTextFieldConstraints = [self.passwordTextFieldHeight, self.passwordTextFieldBottomSpacing]
        
        // Show login text fields on load.
        self.showSignup(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        usernameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Helpers

extension LoginViewController {
    func showSignup(show: Bool) {
        if show {
            self.signupTextFieldConstraints.forEach({ $0.constant = self.textFieldOriginalHeight })
            self.loginTextFieldConstraints.forEach({ $0.constant = 0 })
            
        } else {
            self.signupTextFieldConstraints.forEach({ $0.constant = 0 })
            self.loginTextFieldConstraints.forEach({ $0.constant = self.textFieldOriginalHeight })
        }
    }
    
    func transitionToApp() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        UIView.transitionWithView(self.view.window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.view.window!.rootViewController = appDelegate.hamburgerViewController
            let reelStoryboard = UIStoryboard(name: "Reel", bundle: nil)
            let reelNavigationController = reelStoryboard.instantiateViewControllerWithIdentifier("ReelNavigationController") as! UINavigationController
            
            appDelegate.hamburgerViewController?.contentViewController = reelNavigationController
            appDelegate.menuViewController.tableView.reloadData()
            
            }, completion: nil)
    }
}


// MARK: Actions

extension LoginViewController {
    // Records login/signup information.
    @IBAction func signupPressed(sender: AnyObject) {
        
        if self.loginView.frame.height == self.loginViewOriginalHeight {
            self.showSignup(true)
            
        } else {
            
            
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
    }
    
    // Logs in with username (not email) and password.
    @IBAction func loginPressed(sender: AnyObject) {
        
        if self.loginView.frame.height == self.loginViewOriginalHeight {
            
            // TODO: Check that text field text is not null.
            PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) { (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    
                    print("LOGIN SUCCESSFUL")
                    
                    self.emailTextField.resignFirstResponder()
                    self.usernameTextField.resignFirstResponder()
                    self.passwordTextField.resignFirstResponder()
                    
                    self.transitionToApp()
                    
                } else {
                    
                    print("LOGIN FAILED")
                    
                    let invalidLoginAlertVC = UIAlertController(title: "Invalid Username or Password", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    invalidLoginAlertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(invalidLoginAlertVC, animated: true, completion: nil)
                }
            }
            
        } else {
            self.showSignup(false)
        }
    }
    
    @IBAction func onBackgroundTapped(sender: AnyObject) {
        self.view.endEditing(true)
        
        print("BACKGROUND TAPPED")
    }
}


// MARK: - Mail Compose View Controller Delegate

extension LoginViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        // TODO: Handle each mail case? i.e. sent, not sent, etc.
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presentReportUserMailCompose() {
        if MFMailComposeViewController.canSendMail() {
            let subject = "THE DELT: User Signup Request"
            let recipient = "thedeltusa@gmail.com"
            var body = "Name: "
            if let name = self.nameTextField.text {
                body += name
            }
            body += "\nEmail:"
            if let email = self.emailTextField.text {
                body += email
            }
            body += "\nUsername:"
            if let username = self.usernameTextField.text {
                body += username
            }
            
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setSubject(subject)
            mailComposeVC.setToRecipients([recipient])
            mailComposeVC.setMessageBody(body, isHTML: false)
            
            
            // mailComposeVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
            // UINavigationBar.appearance().barStyle = .Black
            
            self.presentViewController(mailComposeVC, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Mail Not Enabled", message: "Could not send signup request. Please set up a mail account for your device and try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
