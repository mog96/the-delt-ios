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
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var deltLoadingView: DeltLoadingView!
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
    
    var loginLabel: UILabel!
    var loginLabelOriginalOrigin: CGPoint!
    let loginString = "LOG IN"
    let loggingInString = "LOGGING IN..."
    
    var loginButtonOriginalColor: UIColor!
    var signupButtonOriginalColor: UIColor!
    
    var loginViewLoginHeight: CGFloat!
    
    var textFieldOriginalHeight: CGFloat!
    
    var textFields: [UITextField]!
    var signupTextFieldConstraints: [NSLayoutConstraint]!
    var loginTextFieldConstraints: [NSLayoutConstraint]!
    var controlsHiddenOnLogin: [UIControl]!
    
    let loginBackgroundImageNames = ["LOGIN BACKGROUND 1", "OUTER SPACE"]
    var loginBackgroundImageIndex = 0
    
    var lastFirstResponder: UITextField?
    
    var shouldContinueAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundImageView.image = UIImage(named: self.loginBackgroundImageNames[self.loginBackgroundImageIndex])
        
        self.deltLoadingView.hidden = true
        
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
        
        // Group buttons and text fields for animations.
        self.textFieldOriginalHeight = self.nameTextFieldHeight.constant
        self.textFields = [self.nameTextField, self.emailTextField, self.usernameTextField, self.passwordTextField]
        self.signupTextFieldConstraints = [self.nameTextFieldHeight, self.nameTextFieldBottomSpacing, self.emailTextFieldHeight, self.emailTextFieldBottomSpacing]
        self.loginTextFieldConstraints = [self.passwordTextFieldHeight, self.passwordTextFieldBottomSpacing]
        self.controlsHiddenOnLogin = [self.usernameTextField, self.passwordTextField, self.signupButton]
        
        // Login and sign up button colors.
        self.loginButtonOriginalColor = self.loginButton.titleColorForState(.Normal)
        self.signupButtonOriginalColor = self.signupButton.titleColorForState(.Normal)
        
        // Show login text fields on load.
        self.showSignup(false)
        // Must come after above line to ensure login view is proper height.
        self.loginView.layer.cornerRadius = 3
        self.loginView.layer.masksToBounds = true
        self.loginView.setNeedsLayout()
        self.loginView.layoutIfNeeded()
        self.loginViewLoginHeight = self.loginView.frame.height
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.usernameTextField.becomeFirstResponder()
        
        self.addLoginLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Helpers

extension LoginViewController {
    
    // Login label used as duplicate of login button title label for animations.
    private func addLoginLabel() {
        self.loginLabel = UILabel()
        self.loginLabel.text = self.loginButton.titleLabel!.text
        self.loginLabel.textColor = self.loginButton.titleLabel!.textColor
        self.loginLabel.font = self.loginButton.titleLabel!.font
        let loginButtonTitleLabelFrame = self.loginButton.convertRect(self.loginButton.titleLabel!.frame, toView: self.view)
        self.loginLabel.frame = CGRect(x: loginButtonTitleLabelFrame.origin.x, y: loginButtonTitleLabelFrame.origin.y, width: loginButtonTitleLabelFrame.width, height: loginButtonTitleLabelFrame.height)
        self.loginLabelOriginalOrigin = self.loginLabel.frame.origin
        self.loginLabel.hidden = true
        self.view.addSubview(self.loginLabel)
        
        self.exemptLoginLabelFrameFromDeltAnimation()
    }
    
    private func exemptLoginLabelFrameFromDeltAnimation() {
        self.loginLabel.text = self.loggingInString
        self.loginLabel.sizeToFit()
        self.loginLabel.center.x = self.loginView.center.x
        self.deltLoadingView.addExemptFrames(self.loginLabel.frame)
        self.loginLabel.text = self.loginString
        self.loginLabel.sizeToFit()
        self.loginLabel.frame.origin.x = self.loginLabelOriginalOrigin.x
    }
    
    private func showSignup(show: Bool) {
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
    
    private func startLoginAnimation() {
        self.view.endEditing(true)
        
        self.shouldContinueAnimating = true
        
        self.loginLabel.hidden = false
        self.loginButton.hidden = true
        UIView.animateWithDuration(0.5, animations: { 
            self.loginLabel.text = self.loggingInString
            self.loginLabel.sizeToFit()
            self.loginLabel.center.x = self.loginView.center.x
            }) { _ in
                self.pulseLoginLabel()
        }
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        UIView.transitionWithView(self.backgroundImageView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            self.backgroundImageView.hidden = true
            }, completion: { _ in
                self.loginBackgroundImageIndex = (self.loginBackgroundImageIndex + 1) % self.loginBackgroundImageNames.count
                self.backgroundImageView.image = UIImage(named: self.loginBackgroundImageNames[self.loginBackgroundImageIndex])
        })
        self.controlsHiddenOnLogin.forEach({ (component: UIControl) in
            UIView.transitionWithView(component, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                component.hidden = true
                }, completion: nil)
        })
        UIView.transitionWithView(self.deltLoadingView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            self.deltLoadingView.startAnimating()
            self.deltLoadingView.hidden = false
            }, completion: nil)
    }
    
    // WARNING: Recursive loop could cause stack overflow.
    private func pulseLoginLabel() {
        UIView.animateWithDuration(1, animations: {
            self.loginLabel.alpha = 0
            }) { _ in
                UIView.animateWithDuration(2, animations: {
                    self.loginLabel.alpha = 1
                    }, completion: { _ in
                        if self.shouldContinueAnimating {
                            self.pulseLoginLabel()
                        }
                })
        }
    }
    
    private func endLoginAnimation() {
        self.shouldContinueAnimating = false
        
        // Return duplicate login label to login button title label's position.
        UIView.animateWithDuration(0.5, animations: {
            self.loginLabel.text = self.loginString
            self.loginLabel.sizeToFit()
            self.loginLabel.frame.origin.x = self.loginLabelOriginalOrigin.x
            }, completion: { _ in
                self.loginButton.hidden = false
                self.loginLabel.hidden = true
        })
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UIView.transitionWithView(self.backgroundImageView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            self.backgroundImageView.hidden = false
            }, completion: nil)
        self.controlsHiddenOnLogin.forEach({ (component: UIControl) in
            UIView.transitionWithView(component, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                component.hidden = false
                }, completion: nil)
        })
        UIView.transitionWithView(self.deltLoadingView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            self.deltLoadingView.hidden = true
            self.deltLoadingView.stopAnimating()
            }, completion: nil)
        
        self.lastFirstResponder?.becomeFirstResponder()
    }
    
    private func transitionToApp() {
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


// MARK: - Signup Helpers

extension LoginViewController {
    private func submitSignupRequest() {
        let signupRequest = PFObject(className: "SignupRequest")
        signupRequest["name"] = self.nameTextField.text
        if let email = self.emailTextField.text {
            self.checkEmail(email, forRequest: signupRequest)
        } else {
            let alert = UIAlertController(title: "Email Required", message: "Please enter an email address.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private func checkEmail(email: String, forRequest signupRequest: PFObject) {
        let query = PFUser.query()
        query?.whereKey("email", equalTo: email)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
            if error != nil {
                print("Error:", error?.userInfo["error"])
                self.presentErrorSubmittingRequestAlert()
            } else {
                if objects?.count == 0 {
                    signupRequest["email"] = email
                    if let username = self.usernameTextField.text {
                        self.checkUsername(username, forRequest: signupRequest)
                    } else {
                        let alert = UIAlertController(title: "Username Required", message: "Please enter a username.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    let alert = UIAlertController(title: "Email In Use", message: "The email you entered is already associated with an account. If that doesn't sound right, please contact your Admin.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    private func checkUsername(username: String, forRequest signupRequest: PFObject) {
        let query = PFUser.query()
        query?.whereKey("username", equalTo: username)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
            if error != nil {
                print("Error:", error?.userInfo["error"])
                self.presentErrorSubmittingRequestAlert()
            } else {
                if objects?.count == 0 {
                    signupRequest["username"] = username
                    signupRequest.saveInBackgroundWithBlock({ (completed: Bool, error: NSError?) -> Void in
                        if let error = error {
                            // Log details of the failure
                            print("Error: \(error) \(error.userInfo)")
                            self.presentErrorSubmittingRequestAlert()
                            
                        } else {
                            let alert = UIAlertController(title: "Signup Request Submitted", message: "The Admin has received your request and will be in touch soon.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { _ in
                                self.showSignup(false)
                                self.usernameTextField.text = nil
                                self.emailTextField.text = nil
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                } else {
                    let alert = UIAlertController(title: "Username Taken", message: "The username you requested is already taken. Please choose another.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    private func presentErrorSubmittingRequestAlert() {
        let alert = UIAlertController(title: "Error Submitting Request", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.lastFirstResponder = textField
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
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
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
            if let email = self.emailTextField.text {
                if email.hasSuffix("@stanford.edu") {
                    self.submitSignupRequest()
                    
                } else {
                    self.presentSignupRequestMailCompose()
                }
                
            } else {
                self.presentSignupRequestMailCompose()
            }
        }
    }
    
    // Logs in with username (not email) and password.
    @IBAction func loginPressed(sender: AnyObject) {
        if self.loginView.frame.height == self.loginViewLoginHeight {
            self.startLoginAnimation()
            
            // TODO: Check that text field text is not null.
            PFUser.logInWithUsernameInBackground(self.usernameTextField.text!, password: self.passwordTextField.text!) { (user: PFUser?, error: NSError?) -> Void in
                
                self.endLoginAnimation()
                
                if user != nil {
                    
                    print("LOGIN SUCCESSFUL")
                    
                    self.emailTextField.resignFirstResponder()
                    self.usernameTextField.resignFirstResponder()
                    self.passwordTextField.resignFirstResponder()
                    
                    self.transitionToApp()
                    
                } else {
                    
                    print("LOGIN FAILED")
                    
                    if let errorString = error?.userInfo["error"] as? String {
                        
                        print("LOGIN ERROR:", errorString)
                        
                        switch errorString {
                        case "Invalid username/password.":
                            let ac = UIAlertController(title: "Invalid Username or Password", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(ac, animated: true, completion: nil)
                        case "Could not connect to the server.":
                            let ac = UIAlertController(title: "Unable to Connect", message: "Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                            self.presentViewController(ac, animated: true, completion: nil)
                        default:
                            let ac = UIAlertController(title: "Server Error", message: "Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(ac, animated: true, completion: nil)
                        }
                    }
                }
            }
            
        } else {
            self.showSignup(false)
        }
    }
    
    @IBAction func onBackgroundTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.lastFirstResponder = nil
    }
}
