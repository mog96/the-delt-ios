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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginTextFieldSpacingHeight: NSLayoutConstraint!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var loginButtonOriginalColor: UIColor!
    var signupButtonOriginalColor: UIColor!
    
    var loginViewOriginalHeight: CGFloat!
    var signupHeightChange: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginView.layer.cornerRadius = 2
        self.loginView.layer.masksToBounds = true
        
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.nameTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.emailTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.usernameTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.passwordTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        
        // emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        self.loginView.setNeedsLayout()
        self.loginView.layoutIfNeeded()
        self.loginViewOriginalHeight = self.loginView.frame.height
        
        // Height change accounts for name and email textfield heights, plus spacing between, and below email text field.
        self.signupHeightChange = self.nameTextField.frame.height * 2 + self.loginTextFieldSpacingHeight.constant * 2
        
        self.loginButtonOriginalColor = self.loginButton.titleColorForState(.Normal)
        self.signupButtonOriginalColor = self.signupButton.titleColorForState(.Normal)
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
    
    // Records login/signup information.
    @IBAction func signupPressed(sender: AnyObject) {
        
        if self.loginView.frame.height == self.loginViewOriginalHeight {
            self.showSignup(true)
            
        } else {
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
    
    
    // MARK: - Helpers
    
    func showSignup(show: Bool) {
        self.loginViewHeightConstraint.constant = self.loginViewOriginalHeight + (show ? self.signupHeightChange : 0)
        self.nameTextField.alpha = show ? 0 : 1
        self.emailTextField.alpha = show ? 0 : 1
        
        if show {
            self.nameTextField.hidden = false
            self.emailTextField.hidden = false
        }
        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.loginView.layoutIfNeeded()
            self.nameTextField.alpha = show ? 1 : 0
            self.emailTextField.alpha = show ? 1 : 0
            self.loginButton.setTitleColor(show ? UIColor.darkGrayColor() : self.loginButtonOriginalColor, forState: .Normal)
            self.signupButton.setTitleColor(show ? self.loginButtonOriginalColor : self.signupButtonOriginalColor, forState: .Normal)
            
            }) { _ in
                if !show {
                    self.nameTextField.hidden = true
                    self.emailTextField.hidden = true
                }
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

    
    /*
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
    */
    
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
            if let name = PFUser.currentUser()?.objectForKey("name") as? String {
                body += "\n" + name
            }
            if let username = PFUser.currentUser()?.username {
                body += "\n" + "Username: " + username
            }
            body += "\n\nUser in question: [enter username]"
            body += "\nComment: [optional]"
            
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setSubject(subject)
            mailComposeVC.setToRecipients([recipient])
            mailComposeVC.setMessageBody(body, isHTML: false)
            
            
            // mailComposeVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
            // UINavigationBar.appearance().barStyle = .Black
            
            self.presentViewController(mailComposeVC, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Mail Not Enabled", message: "Could not send message. Set up a mail account for your device and try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
