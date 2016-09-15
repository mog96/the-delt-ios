//
//  LoginViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//


import UIKit
import MessageUI
import Parse
import Reachability

class LoginViewController: UIViewController {
    
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
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var loginButtonOriginalColor: UIColor!
    var signupButtonOriginalColor: UIColor!
    
    var loginViewLoginHeight: CGFloat!
    
    var textFieldOriginalHeight: CGFloat!
    
    var textFields: [UITextField]!
    var signupTextFieldConstraints: [NSLayoutConstraint]!
    var loginTextFieldConstraints: [NSLayoutConstraint]!
    
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
        
        self.loginButtonOriginalColor = self.loginButton.titleColorForState(.Normal)
        self.signupButtonOriginalColor = self.signupButton.titleColorForState(.Normal)
        
        self.textFieldOriginalHeight = self.nameTextFieldHeight.constant
        
        self.textFields = [self.nameTextField, self.emailTextField, self.usernameTextField, self.passwordTextField]
        self.signupTextFieldConstraints = [self.nameTextFieldHeight, self.nameTextFieldBottomSpacing, self.emailTextFieldHeight, self.emailTextFieldBottomSpacing]
        self.loginTextFieldConstraints = [self.passwordTextFieldHeight, self.passwordTextFieldBottomSpacing]
        
        // Show login text fields on load.
        self.showSignup(false)
        
        // Must come after above line to ensure login view is proper height
        self.loginView.layer.cornerRadius = 2
        self.loginView.layer.masksToBounds = true
        self.loginView.setNeedsLayout()
        self.loginView.layoutIfNeeded()
        self.loginViewLoginHeight = self.loginView.frame.height
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
        self.view.endEditing(true)
        
        let animationDuration = 0.35
        
        if show {
            self.signupTextFieldConstraints.forEach({ $0.constant = self.textFieldOriginalHeight })
            self.loginTextFieldConstraints.forEach({ $0.constant = 0 })
            self.usernameTextField.returnKeyType = .Go
            
        } else {
            self.signupTextFieldConstraints.forEach({ $0.constant = 0 })
            self.loginTextFieldConstraints.forEach({ $0.constant = self.textFieldOriginalHeight })
            self.usernameTextField.returnKeyType = .Next
        }
        
        self.loginView.setNeedsLayout()
        self.textFields.forEach({ $0.setNeedsLayout() })
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.loginView.layoutIfNeeded()
            self.textFields.forEach({ $0.layoutIfNeeded() })
            self.loginButton.setTitleColor(show ? UIColor.darkGrayColor() : self.loginButtonOriginalColor, forState: .Normal)
            self.signupButton.setTitleColor(show ? self.loginButtonOriginalColor : self.signupButtonOriginalColor, forState: .Normal)
            
            }, completion: nil)

        [self.nameTextField, self.emailTextField].forEach { (textField: UITextField) in
            UIView.transitionWithView(textField, duration: animationDuration - 1, options: .TransitionCrossDissolve, animations: {
                textField.hidden = !show
                }, completion: nil)
            }
        
        UIView.transitionWithView(self.passwordTextField, duration: animationDuration - 1, options: .TransitionCrossDissolve, animations: {
            self.passwordTextField.hidden = show
            }, completion: nil)
    }
    
    func transitionToApp() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        UIView.transitionWithView(self.view.window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.view.window!.rootViewController = appDelegate.hamburgerViewController
            let reelStoryboard = UIStoryboard(name: "Reel", bundle: nil)
            let reelNC = reelStoryboard.instantiateViewControllerWithIdentifier("ReelNavigationController") as! UINavigationController
            if let reelVC = reelNC.viewControllers[0] as? ReelViewController {
                reelVC.menuDelegate = appDelegate.menuViewController // Set menu delegate so menu button works for first view shown.
            }
            
            appDelegate.hamburgerViewController?.contentViewController = reelNC
            appDelegate.menuViewController.tableView.reloadData()
            
            }, completion: nil)
    }
}


// MARK: - Text Field Delegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField.returnKeyType {
        case .Go:
            self.goKeyPressed()
        default:
            textField.nextTextField?.becomeFirstResponder()
        }
        return true
    }
}


// MARK: - Mail Compose View Controller Delegate

extension LoginViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        // TODO: Handle each mail case? i.e. sent, not sent, etc.
        
        controller.dismissViewControllerAnimated(true) {
            if result == .Sent {
                let alert = UIAlertController(title: "Thanks for Signing Up!", message: "If your charge has already been added to The Delt, you'll be added immediately. If your charge is not yet using The Delt, we'll be in touch as soon as possible about signing up your charge.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func presentSignupRequestMailCompose() {
        if MFMailComposeViewController.canSendMail() {
            let subject = "Signup Request - " + AppDelegate.appName
            let recipient = "thedeltusa@gmail.com"
            var body = "Please sign me up for The Delt:"
            body += "\nName: "
            if let name = self.nameTextField.text {
                body += name
            }
            body += "\nEmail: "
            if let email = self.emailTextField.text {
                body += email
            }
            body += "\nUsername: "
            if let username = self.usernameTextField.text {
                body += username
            }
            body += "\nTheta Delta Chi Charge: "
            
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


// MARK: Actions

extension LoginViewController {
    func goKeyPressed() {
        if self.loginView.frame.height == self.loginViewLoginHeight {
            self.loginButton.sendActionsForControlEvents(.TouchUpInside)
        } else {
            self.signupButton.sendActionsForControlEvents(.TouchUpInside)
        }
    }
    
    // Records login/signup information.
    @IBAction func signupPressed(sender: AnyObject) {
        self.view.endEditing(true)
        
        if self.loginView.frame.height == self.loginViewLoginHeight {
            self.showSignup(true)
            
        } else {
            self.presentSignupRequestMailCompose()
        }
    }
    
    // Logs in with username (not email) and password.
    @IBAction func loginPressed(sender: AnyObject) {
        if self.loginView.frame.height == self.loginViewLoginHeight {
            
            // TODO: Check that text field text is not null.
            PFUser.logInWithUsernameInBackground(self.usernameTextField.text!, password: self.passwordTextField.text!) { (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    
                    print("LOGIN SUCCESSFUL")
                    
                    self.emailTextField.resignFirstResponder()
                    self.usernameTextField.resignFirstResponder()
                    self.passwordTextField.resignFirstResponder()
                    
                    self.transitionToApp()
                    
                } else {
                    
                    print("LOGIN FAILED")
                    
                    let errorString = error?.userInfo["error"] as! String
                    switch errorString {
                    case "Invalid username/password.":
                        let invalidLoginAlertVC = UIAlertController(title: "Invalid Username or Password", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        invalidLoginAlertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(invalidLoginAlertVC, animated: true, completion: nil)
                    case "Could not connect to the server.":
                        let invalidLoginAlertVC = UIAlertController(title: "Server Error", message: "Could not connect to the server. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                        invalidLoginAlertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(invalidLoginAlertVC, animated: true, completion: nil)
                    default:
                        let invalidLoginAlertVC = UIAlertController(title: "Login Error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        invalidLoginAlertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(invalidLoginAlertVC, animated: true, completion: nil)
                    }
                }
            }
            
        } else {
            self.showSignup(false)
        }
    }
    
    @IBAction func onBackgroundTapped(sender: AnyObject) {
        self.view.endEditing(true)
    }
}
